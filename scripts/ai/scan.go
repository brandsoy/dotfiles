package main

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/BurntSushi/toml"
)

// Server is one configured (or found) MCP server.
type Server struct {
	Client string // client label, e.g. "codex" or "on-disk"
	Name   string
	Path   string // config file it was read from
	Note   string // "disabled", "project: ...", "unparseable: ..."
}

// Skill is one SKILL.md file.
type Skill struct {
	Name string
	Desc string
	Path string
	Link string // non-empty: symlinked install; value is the resolved target
}

// ModelEntry is one locally downloaded model (or model file).
type ModelEntry struct {
	Source string // ollama, lmstudio, huggingface, llama.cpp, omlx, loose
	Name   string
	Path   string
	Size   string
}

// Proc is a running process whose command line mentions "mcp".
type Proc struct {
	Count   int
	Command string
}

// ScanResult is everything the scan collects.
type ScanResult struct {
	Servers []Server
	Running []Proc
	Skills  []Skill
	Models  []ModelEntry
}

func homeDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "ai-scan: %v\n", err)
		os.Exit(1)
	}
	return home
}

func envDefault(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// --- filesystem sweep ---

var pruneNames = map[string]bool{
	"Library": true, ".Trash": true, "node_modules": true, ".git": true,
	".cache": true, ".venv": true, "venv": true, "__pycache__": true,
	".npm": true, ".pnpm-store": true, "site-packages": true, "Caches": true,
}

type sweep struct {
	skills  []string
	mcpJSON []string
	models  []string
}

func runSweep(home string) *sweep {
	s := &sweep{}
	_ = filepath.WalkDir(home, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil // skip unreadable entries
		}
		if d.IsDir() {
			if path != home && pruneNames[d.Name()] {
				return filepath.SkipDir
			}
			return nil
		}
		name := d.Name()
		switch {
		case name == "SKILL.md":
			s.skills = append(s.skills, path)
		case name == "mcp.json" || strings.HasSuffix(name, ".mcp.json"):
			s.mcpJSON = append(s.mcpJSON, path)
		case strings.HasSuffix(name, ".gguf") || strings.HasSuffix(name, ".ggml") ||
			strings.HasSuffix(name, ".safetensors"):
			s.models = append(s.models, path)
		}
		return nil
	})
	sort.Strings(s.skills)
	sort.Strings(s.mcpJSON)
	sort.Strings(s.models)
	return s
}

// --- MCP config parsing ---

var (
	reBlockComment  = regexp.MustCompile(`(?s)/\*.*?\*/`)
	reLineComment   = regexp.MustCompile(`(?m)^\s*//.*$`)
	reTrailingComma = regexp.MustCompile(`,(\s*[\]}])`)
)

// stripJSONC removes comments and trailing commas so JSONC configs parse.
func stripJSONC(text string) string {
	text = reBlockComment.ReplaceAllString(text, "")
	text = reLineComment.ReplaceAllString(text, "")
	return reTrailingComma.ReplaceAllString(text, "$1")
}

type serverName struct {
	Name string
	Note string
}

// parseMCPConfig extracts server names from one config file.
// Modes: vibe, codex, claude, generic (JSON/JSONC).
func parseMCPConfig(path, mode string) []serverName {
	switch mode {
	case "vibe":
		var doc map[string]any
		if _, err := toml.DecodeFile(path, &doc); err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		var out []serverName
		if servers, ok := doc["mcp_servers"].([]map[string]any); ok {
			for _, srv := range servers {
				name, _ := srv["name"].(string)
				if name == "" {
					name = "(unnamed)"
				}
				out = append(out, serverName{Name: name})
			}
		}
		return out
	case "codex":
		var doc map[string]any
		if _, err := toml.DecodeFile(path, &doc); err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		var out []serverName
		if servers, ok := doc["mcp_servers"].(map[string]any); ok {
			names := make([]string, 0, len(servers))
			for name := range servers {
				names = append(names, name)
			}
			sort.Strings(names)
			for _, name := range names {
				note := ""
				if cfg, ok := servers[name].(map[string]any); ok && cfg["enabled"] == false {
					note = "disabled"
				}
				out = append(out, serverName{name, note})
			}
		}
		return out
	case "claude":
		data, err := os.ReadFile(path)
		if err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		var doc map[string]any
		if err := json.Unmarshal(data, &doc); err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		var out []serverName
		out = append(out, mapServerNames(doc["mcpServers"], "")...)
		if projects, ok := doc["projects"].(map[string]any); ok {
			paths := make([]string, 0, len(projects))
			for p := range projects {
				paths = append(paths, p)
			}
			sort.Strings(paths)
			for _, p := range paths {
				if pdata, ok := projects[p].(map[string]any); ok {
					out = append(out, mapServerNames(pdata["mcpServers"], "project: "+p)...)
				}
			}
		}
		return out
	default:
		data, err := os.ReadFile(path)
		if err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		var doc any
		if err := json.Unmarshal([]byte(stripJSONC(string(data))), &doc); err != nil {
			return []serverName{{"(unparseable)", err.Error()}}
		}
		switch t := doc.(type) {
		case map[string]any:
			var out []serverName
			for _, key := range []string{"mcpServers", "servers", "mcp", "context_servers"} {
				table, ok := doc.(map[string]any)[key]
				if !ok {
					continue
				}
				switch table := table.(type) {
				case map[string]any:
					out = append(out, mapServerNames(table, "")...)
				case []any:
					out = append(out, catalogServerNames(table)...)
				}
				if len(out) > 0 {
					break
				}
			}
			return out
		case []any:
			// Top-level catalog: server objects with a name field.
			return catalogServerNames(t)
		}
		return nil
	}
}

// catalogServerNames extracts names from catalog-style server lists.
func catalogServerNames(entries []any) []serverName {
	var out []serverName
	for _, entry := range entries {
		if srv, ok := entry.(map[string]any); ok {
			if name, _ := srv["name"].(string); name != "" {
				out = append(out, serverName{Name: name})
			}
		}
	}
	return out
}

func mapServerNames(v any, note string) []serverName {
	table, ok := v.(map[string]any)
	if !ok {
		return nil
	}
	names := make([]string, 0, len(table))
	for name := range table {
		names = append(names, name)
	}
	sort.Strings(names)
	out := make([]serverName, 0, len(names))
	for _, name := range names {
		out = append(out, serverName{name, note})
	}
	return out
}

type mcpSource struct {
	Label string
	Mode  string
	Path  string
}

func mcpSources(home, vibeHome string) []mcpSource {
	wd, _ := os.Getwd()
	join := filepath.Join
	return []mcpSource{
		{"vibe", "vibe", join(vibeHome, "config.toml")},
		{"vibe (project)", "vibe", join(wd, ".vibe", "config.toml")},
		{"codex", "codex", join(home, ".codex", "config.toml")},
		{"claude-code", "claude", join(home, ".claude.json")},
		{"claude-code", "generic", join(home, ".claude", "settings.json")},
		{"project (shared)", "generic", join(wd, ".mcp.json")},
		{"claude-desktop", "generic", join(home, "Library", "Application Support", "Claude", "claude_desktop_config.json")},
		{"cursor", "generic", join(home, ".cursor", "mcp.json")},
		{"windsurf", "generic", join(home, ".codeium", "windsurf", "mcp_config.json")},
		{"vscode", "generic", join(home, ".vscode", "mcp.json")},
		{"vscode", "generic", join(home, "Library", "Application Support", "Code", "User", "mcp.json")},
		{"gemini", "generic", join(home, ".gemini", "settings.json")},
		{"continue", "generic", join(home, ".continue", "config.json")},
		{"zed", "generic", join(home, ".config", "zed", "settings.json")},
		{"pi", "generic", join(home, ".pi", "agent", "mcp.json")},
		{"pi (project)", "generic", join(wd, ".pi", "mcp.json")},
		{"pig", "generic", join(home, ".config", "pig", "agent", "mcp.json")},
		{"pig (project)", "generic", join(wd, ".pig", "mcp.json")},
		{"oh-my-pi", "generic", join(home, ".omp", "agent", "mcp.json")},
		{"opencode", "generic", join(home, ".config", "opencode", "opencode.json")},
		{"opencode (project)", "generic", join(wd, "opencode.json")},
	}
}

func scanMCPConfigs(home, vibeHome string) []Server {
	var out []Server
	for _, src := range mcpSources(home, vibeHome) {
		if info, err := os.Stat(src.Path); err != nil || info.IsDir() {
			continue
		}
		names := parseMCPConfig(src.Path, src.Mode)
		if len(names) == 0 {
			out = append(out, Server{Client: src.Label, Name: "(no servers configured)", Path: src.Path})
			continue
		}
		for _, n := range names {
			out = append(out, Server{Client: src.Label, Name: n.Name, Path: src.Path, Note: n.Note})
		}
	}
	return out
}

func scanFoundMCP(files []string) []Server {
	var out []Server
	for _, file := range files {
		for _, n := range parseMCPConfig(file, "generic") {
			out = append(out, Server{Client: "on-disk", Name: n.Name, Path: file, Note: n.Note})
		}
	}
	return out
}

func runningMCP() []Proc {
	out, err := exec.Command("ps", "-axo", "command=").Output()
	if err != nil {
		return nil
	}
	counts := map[string]int{}
	for _, line := range strings.Split(string(out), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || !strings.Contains(strings.ToLower(line), "mcp") {
			continue
		}
		if strings.Contains(line, "ai-scan") || strings.Contains(line, "grep -i mcp") {
			continue
		}
		counts[line]++
	}
	procs := make([]Proc, 0, len(counts))
	for cmd, count := range counts {
		procs = append(procs, Proc{Count: count, Command: cmd})
	}
	sort.Slice(procs, func(i, j int) bool {
		if procs[i].Count != procs[j].Count {
			return procs[i].Count > procs[j].Count
		}
		return procs[i].Command < procs[j].Command
	})
	return procs
}

// --- skills ---

func scanSkills(paths []string) []Skill {
	out := make([]Skill, 0, len(paths))
	for _, path := range paths {
		out = append(out, Skill{
			Name: filepath.Base(filepath.Dir(path)),
			Desc: skillDescription(path),
			Path: path,
		})
	}
	sort.Slice(out, func(i, j int) bool {
		if out[i].Name != out[j].Name {
			return out[i].Name < out[j].Name
		}
		return out[i].Path < out[j].Path
	})
	return out
}

// skillDescription pulls the frontmatter description (first "description:"
// line; handles quoted values and folded/block styles).
func skillDescription(path string) string {
	data, err := os.ReadFile(path)
	if err != nil {
		return ""
	}
	lines := strings.Split(string(data), "\n")
	for i, line := range lines {
		if !strings.HasPrefix(line, "description:") {
			continue
		}
		value := strings.TrimSpace(strings.TrimPrefix(line, "description:"))
		value = strings.Trim(value, `"'`)
		if strings.HasPrefix(value, ">") || strings.HasPrefix(value, "|") {
			// Folded/block description: take the first following non-empty line.
			for j := i + 1; j < len(lines); j++ {
				if trimmed := strings.TrimSpace(lines[j]); trimmed != "" {
					return trimmed
				}
			}
			return ""
		}
		return value
	}
	return ""
}

// symlinkedSkillInstalls finds skill roots wired up via symlinked
// directories, which the sweep (like find) cannot see.
func symlinkedSkillInstalls(home, vibeHome string) []Skill {
	roots := []string{
		filepath.Join(vibeHome, "skills"),
		filepath.Join(home, ".pi", "agent", "skills"),
		filepath.Join(home, ".config", "pig", "agent", "skills"),
		filepath.Join(home, ".omp", "agent", "skills"),
		filepath.Join(home, ".codex", "skills"),
	}
	var out []Skill
	for _, root := range roots {
		entries, err := os.ReadDir(root)
		if err != nil {
			continue
		}
		for _, e := range entries {
			if e.Type()&fs.ModeSymlink == 0 {
				continue
			}
			linkPath := filepath.Join(root, e.Name())
			if _, err := os.Stat(filepath.Join(linkPath, "SKILL.md")); err != nil {
				continue
			}
			target, err := filepath.EvalSymlinks(linkPath)
			if err != nil {
				continue
			}
			out = append(out, Skill{Name: e.Name(), Path: linkPath, Link: target})
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Path < out[j].Path })
	return out
}

// --- models ---

func humanSize(n int64) string {
	if n < 1024 {
		return fmt.Sprintf("%d B", n)
	}
	f := float64(n)
	units := []string{"KB", "MB", "GB", "TB", "PB"}
	for _, unit := range units {
		f /= 1024
		if f < 1024 || unit == "PB" {
			return fmt.Sprintf("%.1f %s", f, unit)
		}
	}
	return fmt.Sprintf("%.1f PB", f)
}

func fileSize(path string) string {
	if info, err := os.Stat(path); err == nil {
		return humanSize(info.Size())
	}
	return "?"
}

func dirSize(path string) string {
	var total int64
	_ = filepath.WalkDir(path, func(_ string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		if info, err := d.Info(); err == nil && info.Mode().IsRegular() {
			total += info.Size()
		}
		return nil
	})
	return humanSize(total)
}

type ollamaManifest struct {
	Layers []struct {
		Size int64 `json:"size"`
	} `json:"layers"`
}

func ollamaManifests(manifestRoot string) []ModelEntry {
	var out []ModelEntry
	_ = filepath.WalkDir(manifestRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return nil
		}
		rel, err := filepath.Rel(manifestRoot, path)
		if err != nil {
			return nil
		}
		parts := strings.Split(rel, string(filepath.Separator))
		var name string
		switch len(parts) {
		case 4:
			name = parts[1] + "/" + parts[2] + ":" + parts[3]
		case 3:
			name = parts[1] + ":" + parts[2]
		case 2:
			name = parts[0] + ":" + parts[1]
		default:
			name = strings.Join(parts, ":")
		}
		size := "?"
		if data, err := os.ReadFile(path); err == nil {
			var manifest ollamaManifest
			if json.Unmarshal(data, &manifest) == nil {
				var total int64
				for _, layer := range manifest.Layers {
					total += layer.Size
				}
				size = humanSize(total)
			}
		}
		out = append(out, ModelEntry{Source: "ollama", Name: name, Path: manifestRoot, Size: size})
		return nil
	})
	sort.Slice(out, func(i, j int) bool { return out[i].Name < out[j].Name })
	return out
}

func scanModels(home string, sweepModels []string) []ModelEntry {
	join := filepath.Join
	aiModelsHome := envDefault("AI_MODELS_HOME", join(home, "Models"))
	var out []ModelEntry
	var excludes []string
	seen := map[string]bool{}

	record := func(root string) bool {
		if root == "" || seen[root] {
			return false
		}
		seen[root] = true
		if info, err := os.Stat(root); err != nil || !info.IsDir() {
			return false
		}
		excludes = append(excludes, root+string(filepath.Separator))
		return true
	}

	// Ollama, honoring OLLAMA_MODELS and the AI_MODELS_HOME convention.
	for _, root := range []string{
		os.Getenv("OLLAMA_MODELS"),
		join(aiModelsHome, "ollama"),
		join(home, ".ollama", "models"),
	} {
		manifestRoot := join(root, "manifests")
		if record(root) && isDir(manifestRoot) {
			out = append(out, ollamaManifests(manifestRoot)...)
		}
	}

	// LM Studio.
	for _, root := range []string{
		join(home, ".lmstudio", "models"),
		join(home, ".cache", "lm-studio", "models"),
	} {
		if record(root) {
			for _, file := range sweepModels {
				if strings.HasPrefix(file, root+string(filepath.Separator)) {
					out = append(out, ModelEntry{Source: "lmstudio", Name: filepath.Base(file), Path: file, Size: fileSize(file)})
				}
			}
		}
	}

	// HuggingFace hub caches.
	for _, root := range []string{
		join(envDefault("HF_HOME", join(home, ".cache", "huggingface")), "hub"),
		join(home, ".cache", "huggingface", "hub"),
		join(aiModelsHome, "huggingface", "hub"),
	} {
		if !record(root) {
			continue
		}
		entries, err := os.ReadDir(root)
		if err != nil {
			continue
		}
		names := make([]string, 0, len(entries))
		for _, e := range entries {
			if e.IsDir() && strings.HasPrefix(e.Name(), "models--") {
				names = append(names, e.Name())
			}
		}
		sort.Strings(names)
		for _, name := range names {
			dir := join(root, name)
			model := strings.ReplaceAll(strings.TrimPrefix(name, "models--"), "--", "/")
			out = append(out, ModelEntry{Source: "huggingface", Name: model, Path: dir, Size: dirSize(dir)})
		}
	}

	// llama.cpp download cache.
	for _, root := range []string{
		join(home, ".cache", "llama.cpp"),
		join(aiModelsHome, "llama.cpp"),
	} {
		if !record(root) {
			continue
		}
		entries, err := os.ReadDir(root)
		if err != nil {
			continue
		}
		names := make([]string, 0, len(entries))
		for _, e := range entries {
			if e.IsDir() {
				names = append(names, e.Name())
			}
		}
		sort.Strings(names)
		for _, name := range names {
			dir := join(root, name)
			out = append(out, ModelEntry{Source: "llama.cpp", Name: name, Path: dir, Size: dirSize(dir)})
		}
	}

	// omlx: cache size plus model names from its settings file.
	omlxRoot := join(home, ".omlx")
	if record(omlxRoot) {
		entry := ModelEntry{Source: "omlx", Name: "(cache)", Path: join(omlxRoot, "cache"), Size: dirSize(join(omlxRoot, "cache"))}
		out = append(out, entry)
		if data, err := os.ReadFile(join(omlxRoot, "model_settings.json")); err == nil {
			var doc struct {
				Models map[string]any `json:"models"`
			}
			if json.Unmarshal(data, &doc) == nil {
				names := make([]string, 0, len(doc.Models))
				for name := range doc.Models {
					names = append(names, name)
				}
				sort.Strings(names)
				for _, name := range names {
					out = append(out, ModelEntry{Source: "omlx", Name: strings.ReplaceAll(name, "--", "/"), Path: join(omlxRoot, "model_settings.json")})
				}
			}
		}
	}

	// Loose model files outside the known roots.
	for _, file := range sweepModels {
		skip := false
		for _, prefix := range excludes {
			if strings.HasPrefix(file, prefix) {
				skip = true
				break
			}
		}
		if skip {
			continue
		}
		entry := ModelEntry{Source: "loose", Name: filepath.Base(file), Path: file, Size: fileSize(file)}
		if info, err := os.Lstat(file); err == nil && info.Mode()&fs.ModeSymlink != 0 {
			if target, err := filepath.EvalSymlinks(file); err == nil {
				entry.Size = "symlink -> " + target
			}
		}
		out = append(out, entry)
	}
	return out
}

func isDir(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.IsDir()
}

// --- top level ---

func runScan() ScanResult {
	home := homeDir()
	vibeHome := envDefault("VIBE_HOME", filepath.Join(home, ".vibe"))
	sw := runSweep(home)
	skills := append(scanSkills(sw.skills), symlinkedSkillInstalls(home, vibeHome)...)
	return ScanResult{
		Servers: append(scanMCPConfigs(home, vibeHome), scanFoundMCP(sw.mcpJSON)...),
		Running: runningMCP(),
		Skills:  skills,
		Models:  scanModels(home, sw.models),
	}
}
