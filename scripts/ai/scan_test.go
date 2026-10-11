package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestScanModelsDeduplicatesSymlinkedOllamaRoots(t *testing.T) {
	home := t.TempDir()
	modelsHome := filepath.Join(home, "Models")
	root := filepath.Join(modelsHome, "ollama")
	manifest := filepath.Join(root, "manifests", "registry.ollama.ai", "library", "gemma4", "12b-mlx")
	if err := os.MkdirAll(filepath.Dir(manifest), 0700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(manifest, []byte(`{"layers":[{"size":123}]}`), 0600); err != nil {
		t.Fatal(err)
	}
	ollamaDir := filepath.Join(home, ".ollama")
	if err := os.MkdirAll(ollamaDir, 0700); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(root, filepath.Join(ollamaDir, "models")); err != nil {
		t.Fatal(err)
	}
	t.Setenv("AI_MODELS_HOME", modelsHome)
	t.Setenv("OLLAMA_MODELS", filepath.Join(ollamaDir, "models"))
	t.Setenv("HF_HOME", filepath.Join(home, "huggingface"))
	got := scanModels(home, nil)
	if len(got) != 1 || got[0].Name != "library/gemma4:12b-mlx" {
		t.Fatalf("symlinked Ollama roots should yield one model, got %+v", got)
	}
}

func TestScanModelsDoesNotTreatSettingsAsModel(t *testing.T) {
	home := t.TempDir()
	t.Setenv("AI_MODELS_HOME", filepath.Join(home, "models"))
	t.Setenv("OLLAMA_MODELS", filepath.Join(home, "ollama"))
	t.Setenv("HF_HOME", filepath.Join(home, "huggingface"))
	omlx := filepath.Join(home, ".omlx")
	if err := os.MkdirAll(omlx, 0700); err != nil {
		t.Fatal(err)
	}
	settings := `{"models":{"mlx-community/Qwen3.8-27B-4bit":{}}}`
	if err := os.WriteFile(filepath.Join(omlx, "model_settings.json"), []byte(settings), 0600); err != nil {
		t.Fatal(err)
	}
	if got := scanModels(home, nil); len(got) != 0 {
		t.Fatalf("settings-only model must not be detected: %+v", got)
	}
	cache := filepath.Join(omlx, "cache")
	if err := os.Mkdir(cache, 0700); err != nil {
		t.Fatal(err)
	}
	got := scanModels(home, nil)
	if len(got) != 1 || got[0].Name != "(cache)" {
		t.Fatalf("expected only actual cache summary, got %+v", got)
	}
}
