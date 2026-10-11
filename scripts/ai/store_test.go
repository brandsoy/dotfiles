package main

import (
	"os"
	"path/filepath"
	"reflect"
	"testing"
)

func TestPersistedResults(t *testing.T) {
	path := filepath.Join(t.TempDir(), "ai-scan", "results.json")
	if _, err := loadResults(path); err != nil {
		t.Fatalf("missing store: %v", err)
	}
	original := ScanResult{
		Servers: []Server{{Client: "codex", Name: "server"}},
		Running: []Proc{{Count: 2, Command: "mcp"}},
		Skills:  []Skill{{Name: "skill", Path: "/skills/SKILL.md"}},
		Models:  []ModelEntry{{Name: "Llama-2", Size: "1 GB"}},
	}
	if err := saveResults(path, original); err != nil {
		t.Fatal(err)
	}
	loaded, err := loadResults(path)
	if err != nil || !reflect.DeepEqual(loaded, original) {
		t.Fatalf("round trip: result=%+v err=%v", loaded, err)
	}
	updated := mergeResults(loaded, ScanResult{Models: []ModelEntry{{Name: "Qwen3"}}}, secModels)
	if err := saveResults(path, updated); err != nil {
		t.Fatal(err)
	}
	loaded, err = loadResults(path)
	if err != nil || !reflect.DeepEqual(loaded.Servers, original.Servers) || !reflect.DeepEqual(loaded.Skills, original.Skills) || !reflect.DeepEqual(loaded.Running, original.Running) || loaded.Models[0].Name != "Qwen3" {
		t.Fatal("a partial rescan must persist updates without losing other tools")
	}
	m := newModel()
	m.result = loaded
	m.setItems(loaded)
	if m.Init() != nil || m.loading || m.totals[secModels] != 1 {
		t.Fatal("saved results must load without a scan")
	}
	info, err := os.Stat(path)
	if err != nil || info.Mode().Perm() != 0600 {
		t.Fatal("saved results must be private")
	}
	if err := os.WriteFile(path, []byte("broken JSON"), 0600); err != nil {
		t.Fatal(err)
	}
	if _, err := loadResults(path); err == nil {
		t.Fatal("invalid saved results must report an error")
	}
	if err := saveResults(filepath.Join(path, "blocked.json"), original); err == nil {
		t.Fatal("save failures must report an error")
	}
}
