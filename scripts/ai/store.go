package main

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
)

func resultsPath() (string, error) {
	dir, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "ai-scan", "results.json"), nil
}

func loadResults(path string) (ScanResult, error) {
	var result ScanResult
	data, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return result, nil
	}
	if err != nil {
		return result, err
	}
	err = json.Unmarshal(data, &result)
	return result, err
}

func saveResults(path string, result ScanResult) error {
	data, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return err
	}
	file, err := os.CreateTemp(filepath.Dir(path), ".results-*")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	if _, err := file.Write(data); err != nil {
		file.Close()
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return os.Rename(file.Name(), path)
}

func mergeResults(previous, fresh ScanResult, target section) ScanResult {
	if target == secMCP || target == sectionCount {
		previous.Servers, previous.Running = fresh.Servers, fresh.Running
	}
	if target == secSkills || target == sectionCount {
		previous.Skills = fresh.Skills
	}
	if target == secModels || target == sectionCount {
		previous.Models = fresh.Models
	}
	return previous
}
