package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
)

func TestCodePreview(t *testing.T) {
	preview := codePreview(map[string]string{"foreground": "#ffffff", "background": "#000000"})
	for _, part := range []string{"// A small Go example", "func greet(name string)", `fmt.Println("Hello, " + name)`} {
		if !strings.Contains(preview, part) {
			t.Errorf("preview missing %q: %q", part, preview)
		}
	}
}

func TestSelectTerminalDefaults(t *testing.T) {
	root := t.TempDir()
	themes, err := load(root)
	if err != nil {
		t.Fatal(err)
	}
	command := filepath.Join(root, "theme-switcher")
	if err := os.WriteFile(command, []byte("#!/bin/sh\n[ \"$*\" = 'set terminal-defaults' ]\n"), 0700); err != nil {
		t.Fatal(err)
	}
	m := model{themes: themes, command: command, width: 90, height: 24}
	if !strings.Contains(m.View(), "Terminal defaults") {
		t.Fatal("terminal defaults is missing from the picker")
	}
	updated, _ := m.Update(tea.KeyMsg{Type: tea.KeyEnter})
	if got := updated.(model); got.current != defaultTheme || got.message != "Applied Terminal defaults" {
		t.Fatalf("picker did not apply terminal defaults: %s", got.message)
	}
}
