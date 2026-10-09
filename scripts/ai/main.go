// ai-scan is a TUI that inventories AI tooling on this machine: configured
// MCP servers, agent skill files, and locally downloaded LLM models.
package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	print := flag.Bool("print", false, "print scan results as text instead of opening the TUI")
	flag.Parse()

	if *print {
		printResult(runScan())
		return
	}
	if _, err := tea.NewProgram(newModel(), tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintf(os.Stderr, "ai-scan: %v\n", err)
		os.Exit(1)
	}
}

// printResult renders the scan result as plain text (verification mode).
func printResult(res ScanResult) {
	var b strings.Builder

	b.WriteString("==> MCP servers\n")
	for _, srv := range res.Servers {
		line := srv.Client + "  " + srv.Name
		if srv.Note != "" {
			line += "  (" + srv.Note + ")"
		}
		b.WriteString("    " + line + "\n")
	}
	b.WriteString("\n==> running MCP server processes\n")
	for _, proc := range res.Running {
		b.WriteString(fmt.Sprintf("    %d x %s\n", proc.Count, proc.Command))
	}

	b.WriteString(fmt.Sprintf("\n==> skill files (%d)\n", len(res.Skills)))
	for _, skill := range res.Skills {
		b.WriteString("    " + skill.Name)
		if skill.Link != "" {
			b.WriteString(" -> " + skill.Link)
		} else if skill.Desc != "" {
			b.WriteString(" - " + skill.Desc)
		}
		b.WriteString("\n")
	}

	b.WriteString(fmt.Sprintf("\n==> local LLM models (%d)\n", len(res.Models)))
	for _, entry := range res.Models {
		b.WriteString("    " + entry.Source + "  " + entry.Name)
		if entry.Size != "" {
			b.WriteString("  (" + entry.Size + ")")
		}
		b.WriteString("\n")
	}

	os.Stdout.WriteString(b.String())
}
