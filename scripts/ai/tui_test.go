package main

import (
	"fmt"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

func TestLaunchMenuRequiresSelection(t *testing.T) {
	m := newModel()
	if m.Init() != nil || m.loading {
		t.Fatal("startup must not schedule a scan")
	}
	updated, _ := m.Update(tea.WindowSizeMsg{Width: 90, Height: 40})
	m = updated.(model)
	for _, want := range []string{"CONTROL DECK", "MCP servers", "Skills", "Local models", "Everything"} {
		if !strings.Contains(m.View(), want) {
			t.Fatalf("menu missing %q", want)
		}
	}
	updated, cmd := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'2'}})
	m = updated.(model)
	if cmd != nil || m.loading || m.cursor != 1 {
		t.Fatal("selecting a command must not start scanning")
	}
	updated, cmd = m.Update(tea.KeyMsg{Type: tea.KeyEnter})
	m = updated.(model)
	if cmd != nil || m.loading || !m.ready || m.active != secSkills {
		t.Fatal("Enter must open saved results without scanning")
	}
	updated, _ = m.Update(tea.KeyMsg{Type: tea.KeyEsc})
	updated, cmd = updated.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'r'}})
	m = updated.(model)
	if cmd == nil || !m.loading || m.active != secSkills {
		t.Fatal("r must explicitly start the selected scan")
	}
	updated, _ = m.Update(scanDoneMsg{})
	updated, cmd = updated.Update(tea.KeyMsg{Type: tea.KeyEsc})
	m = updated.(model)
	if cmd != nil || m.ready || m.loading || !strings.Contains(m.View(), "CONTROL DECK") {
		t.Fatal("Escape must return to the idle menu")
	}
}

func TestRescanSelectedSection(t *testing.T) {
	updated, _ := newModel().Update(scanDoneMsg{result: ScanResult{
		Servers: []Server{{Client: "codex", Name: "server"}},
		Models:  []ModelEntry{{Name: "Llama-2"}},
	}})
	m := updated.(model)
	m.active = secModels
	m.chosen[secModels] = "Llama"
	updated, cmd := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'r'}})
	m = updated.(model)
	if cmd == nil || !m.loading || m.active != secModels {
		t.Fatal("r must schedule a scan of the active section")
	}
	updated, _ = m.Update(scanDoneMsg{rescan: true, result: ScanResult{
		Models: []ModelEntry{{Name: "Llama-3"}, {Name: "Qwen3"}},
	}})
	m = updated.(model)
	if m.loading || m.chosen[secModels] != "Llama" || len(m.lists[secModels].Items()) != 1 || m.lists[secModels].Items()[0].(item).title != "Llama-3" {
		t.Fatal("rescan must refresh the selected group")
	}
	if m.totals[secMCP] != 1 || len(m.entries[secMCP]["codex"]) != 1 {
		t.Fatal("rescan must preserve other sections")
	}
	updated, _ = m.Update(scanDoneMsg{rescan: true})
	m = updated.(model)
	if m.chosen[secModels] != "" {
		t.Fatal("a removed group must return to the group menu")
	}
	updated, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'/'}})
	updated, _ = updated.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'r'}})
	if updated.(model).loading {
		t.Fatal("typing r in a filter must not rescan")
	}
}

func TestOpenSkillInEditor(t *testing.T) {
	m := newModel()
	m.setItems(ScanResult{Skills: []Skill{
		{Name: "normal", Path: "/skills/normal/SKILL.md"},
		{Name: "linked", Path: "/skills/linked", Link: "/shared/linked"},
	}})
	m.ready, m.active = true, secSkills
	updated, cmd := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'e'}})
	if cmd != nil {
		t.Fatal("group menu must not open an editor")
	}
	updated, _ = updated.Update(tea.KeyMsg{Type: tea.KeyEnter})
	m = updated.(model)
	for i, want := range []string{"/skills/linked/SKILL.md", "/skills/normal/SKILL.md"} {
		m.lists[secSkills].Select(i)
		if got := m.lists[secSkills].SelectedItem().(item).path; got != want {
			t.Fatalf("editor path = %q, want %q", got, want)
		}
		_, cmd = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'e'}})
		if cmd == nil {
			t.Fatal("e must schedule the editor")
		}
	}
	updated, _ = m.Update(editorDoneMsg{err: fmt.Errorf("nvim missing")})
	if !strings.Contains(updated.(model).notice, "nvim missing") {
		t.Fatal("editor errors must be visible")
	}
	updated, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'/'}})
	updated, _ = updated.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'e'}})
	m = updated.(model)
	if !m.lists[secSkills].SettingFilter() || m.lists[secSkills].FilterInput.Value() != "e" {
		t.Fatal("typing e in a filter must edit the filter")
	}
}

func TestModelsGrouped(t *testing.T) {
	m := newModel()
	m.setItems(ScanResult{Models: []ModelEntry{
		{Name: "unknown.gguf"},
		{Name: "unsloth/Llama-3"},
		{Name: "Meta-Llama-3"},
		{Name: "Llama-2"},
		{Name: "Qwen3"},
		{Name: "Gemma-3"},
	}})
	items := m.groups[secModels].Items()
	want := []string{"All", "Gemma", "Llama", "Qwen", "Unsloth", "Other"}
	if len(items) != len(want) {
		t.Fatalf("got %d models, want %d", len(items), len(want))
	}
	for i, prefix := range want {
		if !strings.HasPrefix(items[i].(item).title, prefix) {
			t.Fatalf("item %d: got %q, want prefix %q", i, items[i].(item).title, prefix)
		}
	}
	if len(m.entries[secModels]["Llama"]) != 2 || m.totals[secModels] != 6 {
		t.Fatal("incorrect group or total count")
	}
	m.ready = true
	m.active = secModels
	m.groups[secModels].Select(2)
	updated, _ := m.Update(tea.KeyMsg{Type: tea.KeyEnter})
	m = updated.(model)
	if m.chosen[secModels] != "Llama" || len(m.lists[secModels].Items()) != 2 {
		t.Fatal("group selection must show only Llama models")
	}
	updated, _ = m.Update(tea.KeyMsg{Type: tea.KeyEsc})
	m = updated.(model)
	if !m.ready || m.chosen[secModels] != "" || m.totals[secModels] != 6 {
		t.Fatal("Escape must return to groups without changing totals")
	}
	if got := modelGroup(ModelEntry{Name: "model.gguf", Path: "/models/unsloth/model.gguf"}); got != "Unsloth" {
		t.Fatalf("path-based group = %q", got)
	}
}

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
	loaded := m.(model)
	if len(loaded.entries[secMCP]["codex"]) != 2 || len(loaded.entries[secMCP]["Running processes"]) != 1 || len(loaded.entries[secSkills]["Pi"]) != 1 || len(loaded.entries[secSkills]["Vibe"]) != 1 {
		t.Fatal("MCP and skills must be grouped by client/install location")
	}
	m, _ = m.Update(tea.WindowSizeMsg{Width: 100, Height: 30})

	for _, sec := range []section{secMCP, secSkills, secModels} {
		m, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'1' + rune(sec)}})
		if !strings.Contains(m.(model).View(), "Choose a group") {
			t.Fatal("each section must start with a group submenu")
		}
		m, _ = m.Update(tea.KeyMsg{Type: tea.KeyEnter})
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
