package main

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	tabStyle       = lipgloss.NewStyle().Padding(0, 1).MarginRight(1)
	activeTabStyle = lipgloss.NewStyle().Padding(0, 1).MarginRight(1).
			Background(lipgloss.Color("62")).Foreground(lipgloss.Color("230"))
	statusStyle = lipgloss.NewStyle().Padding(0, 1).Foreground(lipgloss.Color("241"))
)

type section int

const (
	secMCP section = iota
	secSkills
	secModels
	sectionCount
)

var sectionTitles = [sectionCount]string{"MCP servers", "Skills", "Models"}

// item is the single list item type for all sections.
type item struct {
	title, desc string
}

func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title + " " + i.desc }

type scanDoneMsg struct{ result ScanResult }

type model struct {
	lists   [sectionCount]list.Model
	active  section
	loading bool
	spinner spinner.Model
	ready   bool
	width   int
}

func newModel() model {
	sp := spinner.New()
	sp.Spinner = spinner.Dot

	delegate := list.NewDefaultDelegate()
	l := list.New(nil, delegate, 0, 0)
	l.SetShowHelp(false)
	l.Title = "ai-scan"

	m := model{spinner: sp, loading: true, active: secMCP}
	for i := range m.lists {
		l2 := l
		l2.SetShowTitle(false)
		m.lists[i] = l2
	}
	return m
}

func (m model) Init() tea.Cmd {
	return tea.Batch(m.spinner.Tick, runScanCmd)
}

func runScanCmd() tea.Msg {
	return scanDoneMsg{result: runScan()}
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.resize(msg.Width, msg.Height)
		return m, nil

	case scanDoneMsg:
		m.setItems(msg.result)
		m.loading = false
		m.ready = true
		return m, nil

	case spinner.TickMsg:
		if m.loading {
			var cmd tea.Cmd
			m.spinner, cmd = m.spinner.Update(msg)
			return m, cmd
		}
		return m, nil

	case tea.KeyMsg:
		if !m.lists[m.active].SettingFilter() {
			switch msg.String() {
			case "q", "ctrl+c":
				return m, tea.Quit
			case "tab", "right":
				m.active = (m.active + 1) % sectionCount
				return m, nil
			case "shift+tab", "left":
				m.active = (m.active + sectionCount - 1) % sectionCount
				return m, nil
			case "1", "2", "3":
				m.active = section(int(msg.String()[0] - '1'))
				return m, nil
			}
		}
	}

	var cmd tea.Cmd
	m.lists[m.active], cmd = m.lists[m.active].Update(msg)
	return m, cmd
}

func (m *model) resize(width, height int) {
	listWidth := width - 4
	listHeight := height - 4
	for i := range m.lists {
		m.lists[i].SetWidth(listWidth)
		m.lists[i].SetHeight(listHeight)
	}
}

func (m *model) setItems(res ScanResult) {
	mcp := make([]list.Item, 0, len(res.Servers)+len(res.Running))
	for _, srv := range res.Servers {
		title := srv.Client + ": " + srv.Name
		if srv.Note != "" {
			title += " (" + srv.Note + ")"
		}
		mcp = append(mcp, item{title: title, desc: tildePath(srv.Path)})
	}
	for _, proc := range res.Running {
		mcp = append(mcp, item{
			title: fmt.Sprintf("%d x %s", proc.Count, truncate(proc.Command, 80)),
			desc:  "running MCP server process",
		})
	}
	_ = m.lists[secMCP].SetItems(mcp)

	skills := make([]list.Item, 0, len(res.Skills))
	for _, skill := range res.Skills {
		desc := skill.Desc
		if desc == "" {
			desc = "(no description)"
		}
		if skill.Link != "" {
			desc = "symlink -> " + tildePath(skill.Link)
		} else {
			desc += "  [" + tildePath(skill.Path) + "]"
		}
		skills = append(skills, item{title: skill.Name, desc: desc})
	}
	_ = m.lists[secSkills].SetItems(skills)

	models := make([]list.Item, 0, len(res.Models))
	for _, entry := range res.Models {
		title := entry.Name
		if entry.Size != "" {
			title += "  (" + entry.Size + ")"
		}
		models = append(models, item{title: title, desc: entry.Source + "  " + tildePath(entry.Path)})
	}
	_ = m.lists[secModels].SetItems(models)
}

func (m model) View() string {
	if m.loading {
		return m.spinner.View() + " scanning home directory ..."
	}
	if !m.ready {
		return ""
	}

	var tabs []string
	for i, title := range sectionTitles {
		count := len(m.lists[i].Items())
		label := fmt.Sprintf("%d %s", count, title)
		if section(i) == m.active {
			tabs = append(tabs, activeTabStyle.Render(label))
		} else {
			tabs = append(tabs, tabStyle.Render(label))
		}
	}
	header := lipgloss.NewStyle().Margin(0, 1).Render(
		strings.Join(tabs, "") + strings.Repeat(" ", max(0, m.width-lipgloss.Width(strings.Join(tabs, ""))-4)))
	body := lipgloss.NewStyle().MarginLeft(1).Render(m.lists[m.active].View())
	footer := statusStyle.Render("1/2/3 or tab: section  /: filter  q: quit")
	return header + "\n" + body + "\n" + footer
}

func tildePath(path string) string {
	home := homeDir()
	if strings.HasPrefix(path, home) {
		return "~" + strings.TrimPrefix(path, home)
	}
	return path
}

func truncate(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n-1] + "…"
}
