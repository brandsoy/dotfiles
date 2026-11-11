package main

import (
	"strings"
	"testing"
)

func TestCodePreview(t *testing.T) {
	preview := codePreview(map[string]string{"foreground": "#ffffff", "background": "#000000"})
	for _, part := range []string{"// A small Go example", "func greet(name string)", `fmt.Println("Hello, " + name)`} {
		if !strings.Contains(preview, part) {
			t.Errorf("preview missing %q: %q", part, preview)
		}
	}
}
