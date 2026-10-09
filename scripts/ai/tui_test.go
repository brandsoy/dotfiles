package main

import (
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

func TestViewRendersAllSections(t *testing.T) {
	res := ScanResult{
		Servers: []Server{
			{Client: "codex", Name: "GitKraken", Path: "/home/u/.codex/config.toml"},
			{Client: "codex", Name: "computer-use", Path: "/home/u/.codex/config.toml", Note: "disabled"},
		},
		Running: []Proc{{Count: 4, Command: "gk-alpha mcp"}},
		Skills: []Skill{
			{Name: "my-skill", Desc: "does things", Path: "/home/u/.pi/agent/skills/my-skill/SKILL.md"},
			{Name: "linked", Path: "/home/u/.vibe/skills/linked", Link: "/home/u/.agents/skills/linked"},
		},
		Models: []ModelEntry{
			{Source: "ollama", Name: "library/gemma4:12b-mlx", Path: "/home/u/Models/ollama/manifests", Size: "7.1 GB"},
			{Source: "loose", Name: "model.gguf", Path: "/home/u/model.gguf", Size: "1.0 GB"},
		},
	}

	m, _ := newModel().Update(scanDoneMsg{result: res})
	m, _ = m.Update(tea.WindowSizeMsg{Width: 100, Height: 30})

	for _, sec := range []section{secMCP, secSkills, secModels} {
		m, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'1' + rune(sec)}})
		view := m.(model).View()
		switch sec {
		case secMCP:
			for _, want := range []string{"GitKraken", "disabled", "gk-alpha"} {
				if !strings.Contains(view, want) {
					t.Fatalf("MCP view missing %q", want)
				}
			}
		case secSkills:
			if !strings.Contains(view, "my-skill") || !strings.Contains(view, "does things") {
				t.Fatal("skills view missing entries")
			}
			if !strings.Contains(view, "symlink") {
				t.Fatal("skills view missing symlink note")
			}
		case secModels:
			if !strings.Contains(view, "library/gemma4:12b-mlx") || !strings.Contains(view, "7.1 GB") {
				t.Fatal("models view missing entries")
			}
		}
	}
}
