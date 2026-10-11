package main

import (
	"fmt"
	"os/exec"
	"path/filepath"
	"sort"
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

var menuCommands = []item{
	{title: "MCP servers", desc: "Saved configured servers and running processes"},
	{title: "Skills", desc: "Saved agent skills and symlinked installs"},
	{title: "Local models", desc: "Saved downloaded models and cache sizes"},
	{title: "Everything", desc: "Saved inventory of AI tooling"},
}

// item is the single list item type for all sections.
type item struct {
	title, desc string
	path        string
}

func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title + " " + i.desc }

type editorDoneMsg struct{ err error }

type scanDoneMsg struct {
	result ScanResult
	rescan bool
	err    error
}

type model struct {
	lists   [sectionCount]list.Model
	groups  [sectionCount]list.Model
	entries [sectionCount]map[string][]list.Item
	chosen  [sectionCount]string
	totals  [sectionCount]int
	active  section
	loading bool
	spinner spinner.Model
	ready   bool
	width   int
	height  int
	cursor  int
	result  ScanResult
	store   string
	notice  string
}

func newModel() model {
	sp := spinner.New()
	sp.Spinner = spinner.Dot

	delegate := list.NewDefaultDelegate()
	l := list.New(nil, delegate, 0, 0)
	l.SetShowHelp(false)
	l.Title = "ai-scan"

	m := model{spinner: sp, active: secMCP}
	for i := range m.lists {
		l2 := l
		l2.SetShowTitle(false)
		m.lists[i] = l2
		m.groups[i] = l2
	}
	return m
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) startScan() (tea.Model, tea.Cmd) {
	target := section(m.cursor)
	m.active = secMCP
	if target < sectionCount {
		m.active = target
	}
	m.loading = true
	m.ready = false
	return m, tea.Batch(m.spinner.Tick, m.scanCmd(target, false))
}

func (m model) scanCmd(target section, rescan bool) tea.Cmd {
	return func() tea.Msg {
		result := mergeResults(m.result, runScanSection(target), target)
		err := saveResults(m.store, result)
		return scanDoneMsg{result: result, rescan: rescan, err: err}
	}
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.resize(msg.Width, msg.Height)
		return m, nil

	case scanDoneMsg:
		m.result = msg.result
		m.notice = "Saved results. Press r to refresh."
		if msg.err != nil {
			m.notice = "Could not save results: " + msg.err.Error()
		}
		if msg.rescan {
			fresh := newModel()
			fresh.resize(m.width, m.height)
			fresh.setItems(msg.result)
			sec := m.active
			m.entries[sec] = fresh.entries[sec]
			m.totals[sec] = fresh.totals[sec]
			m.groups[sec] = fresh.groups[sec]
			m.lists[sec] = fresh.lists[sec]
			if entries, ok := m.entries[sec][m.chosen[sec]]; ok {
				_ = m.lists[sec].SetItems(entries)
			} else {
				m.chosen[sec] = ""
			}
		} else {
			m.setItems(msg.result)
		}
		m.loading = false
		m.ready = true
		return m, nil

	case editorDoneMsg:
		if msg.err != nil {
			m.notice = "Could not open nvim: " + msg.err.Error()
		} else {
			m.notice = "Editor closed. Press r to refresh saved skills."
		}
		return m, nil

	case spinner.TickMsg:
		if m.loading {
			var cmd tea.Cmd
			m.spinner, cmd = m.spinner.Update(msg)
			return m, cmd
		}
		return m, nil

	case tea.KeyMsg:
		if msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
		if m.loading {
			if msg.String() == "q" {
				return m, tea.Quit
			}
			return m, nil
		}
		if !m.ready {
			switch msg.String() {
			case "q", "esc":
				return m, tea.Quit
			case "up", "k", "shift+tab":
				m.cursor = (m.cursor + len(menuCommands) - 1) % len(menuCommands)
			case "down", "j", "tab":
				m.cursor = (m.cursor + 1) % len(menuCommands)
			case "1", "2", "3", "4":
				m.cursor = int(msg.String()[0] - '1')
			case "r":
				return m.startScan()
			case "enter":
				m.active = secMCP
				if section(m.cursor) < sectionCount {
					m.active = section(m.cursor)
				}
				m.ready = true
				return m, nil
			}
			return m, nil
		}
		if !m.currentList().SettingFilter() {
			switch msg.String() {
			case "e":
				if m.active == secSkills && m.chosen[secSkills] != "" {
					if selected, ok := m.lists[secSkills].SelectedItem().(item); ok && selected.path != "" {
						return m, tea.ExecProcess(exec.Command("nvim", "--", selected.path), func(err error) tea.Msg {
							return editorDoneMsg{err: err}
						})
					}
				}
				return m, nil
			case "r":
				m.loading = true
				return m, tea.Batch(m.spinner.Tick, m.scanCmd(m.active, true))
			case "enter":
				if m.chosen[m.active] == "" {
					if selected, ok := m.groups[m.active].SelectedItem().(item); ok {
						m.chosen[m.active] = selected.title
						m.lists[m.active].ResetFilter()
						m.lists[m.active].ResetSelected()
						return m, m.lists[m.active].SetItems(m.entries[m.active][selected.title])
					}
					return m, nil
				}
			case "esc":
				if m.chosen[m.active] != "" {
					m.chosen[m.active] = ""
				} else {
					m.ready = false
				}
				return m, nil
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
	current := m.currentList()
	*current, cmd = current.Update(msg)
	return m, cmd
}

func (m *model) currentList() *list.Model {
	if m.chosen[m.active] == "" {
		return &m.groups[m.active]
	}
	return &m.lists[m.active]
}

func (m *model) resize(width, height int) {
	listWidth := max(1, width-4)
	listHeight := max(1, height-6)
	for i := range m.lists {
		m.lists[i].SetWidth(listWidth)
		m.lists[i].SetHeight(listHeight)
		m.groups[i].SetWidth(listWidth)
		m.groups[i].SetHeight(listHeight)
	}
}

func (m *model) setItems(res ScanResult) {
	for sec := section(0); sec < sectionCount; sec++ {
		m.entries[sec] = map[string][]list.Item{}
		m.chosen[sec] = ""
	}
	mcp := make([]list.Item, 0, len(res.Servers)+len(res.Running))
	for _, srv := range res.Servers {
		title := srv.Client + ": " + srv.Name
		if srv.Note != "" {
			title += " (" + srv.Note + ")"
		}
		mcp = append(mcp, item{title: title, desc: tildePath(srv.Path)})
		m.entries[secMCP][srv.Client] = append(m.entries[secMCP][srv.Client], mcp[len(mcp)-1])
	}
	for _, proc := range res.Running {
		mcp = append(mcp, item{
			title: fmt.Sprintf("%d x %s", proc.Count, truncate(proc.Command, 80)),
			desc:  "running MCP server process",
		})
		m.entries[secMCP]["Running processes"] = append(m.entries[secMCP]["Running processes"], mcp[len(mcp)-1])
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
		path := skill.Path
		if skill.Link != "" {
			path = filepath.Join(path, "SKILL.md")
		}
		skills = append(skills, item{title: skill.Name, desc: desc, path: path})
		group := skillGroup(skill.Path)
		m.entries[secSkills][group] = append(m.entries[secSkills][group], skills[len(skills)-1])
	}
	_ = m.lists[secSkills].SetItems(skills)

	models := make([]list.Item, 0, len(res.Models))
	for _, entry := range res.Models {
		group := modelGroup(entry)
		title := entry.Name
		if entry.Size != "" {
			title += "  (" + entry.Size + ")"
		}
		models = append(models, item{title: title, desc: entry.Source + "  " + tildePath(entry.Path)})
		m.entries[secModels][group] = append(m.entries[secModels][group], models[len(models)-1])
	}
	_ = m.lists[secModels].SetItems(models)
	for sec := section(0); sec < sectionCount; sec++ {
		m.totals[sec] = len(m.lists[sec].Items())
		names := make([]string, 0, len(m.entries[sec]))
		for name := range m.entries[sec] {
			names = append(names, name)
		}
		sort.Slice(names, func(i, j int) bool {
			if names[i] == "Other" || names[j] == "Other" {
				return names[j] == "Other"
			}
			return names[i] < names[j]
		})
		groupItems := []list.Item{item{title: "All", desc: fmt.Sprintf("%d entries", m.totals[sec])}}
		var all []list.Item
		for _, name := range names {
			entries := m.entries[sec][name]
			sort.SliceStable(entries, func(i, j int) bool { return entries[i].(item).title < entries[j].(item).title })
			groupItems = append(groupItems, item{title: name, desc: fmt.Sprintf("%d entries", len(entries))})
			all = append(all, entries...)
		}
		m.entries[sec]["All"] = all
		m.groups[sec].ResetFilter()
		m.groups[sec].ResetSelected()
		_ = m.groups[sec].SetItems(groupItems)
		_ = m.lists[sec].SetItems(all)
	}
}

func skillGroup(path string) string {
	for _, source := range []struct{ path, name string }{
		{"/.config/pig/", "Pig"}, {"/.pi/", "Pi"}, {"/.omp/", "Oh My Pi"},
		{"/.codex/", "Codex"}, {"/.claude/", "Claude"}, {"/.vibe/", "Vibe"},
		{"/.agents/", "Shared agents"}, {"/.cursor/", "Cursor"},
		{"/.gemini/", "Gemini"}, {"/.config/opencode/", "OpenCode"},
	} {
		if strings.Contains(path, source.path) {
			return source.name
		}
	}
	return "Other"
}

// Prefer Unsloth over the base model family when both occur in the name.
func modelGroup(entry ModelEntry) string {
	name := strings.ToLower(entry.Name)
	if strings.Contains(name, "unsloth") || strings.Contains(strings.ToLower(entry.Path), "unsloth") {
		return "Unsloth"
	}
	for _, group := range []string{"Llama", "Qwen", "Gemma", "Mistral", "Mixtral", "DeepSeek", "Phi", "Falcon", "StarCoder", "GLM"} {
		if strings.Contains(name, strings.ToLower(group)) {
			return group
		}
	}
	return "Other"
}

func (m model) View() string {
	if m.loading {
		return m.spinner.View() + " scanning home directory ..."
	}
	if !m.ready {
		return m.menuView()
	}

	var tabs []string
	for i, title := range sectionTitles {
		count := m.totals[i]
		label := fmt.Sprintf("%d %s", count, title)
		if section(i) == m.active {
			tabs = append(tabs, activeTabStyle.Render(label))
		} else {
			tabs = append(tabs, tabStyle.Render(label))
		}
	}
	header := lipgloss.NewStyle().Margin(0, 1).Render(
		strings.Join(tabs, "") + strings.Repeat(" ", max(0, m.width-lipgloss.Width(strings.Join(tabs, ""))-4)))
	label := "Choose a group"
	if m.chosen[m.active] != "" {
		label = m.chosen[m.active]
	}
	body := lipgloss.NewStyle().MarginLeft(1).Render(label + "\n" + m.currentList().View())
	help := "1/2/3 or tab: section  enter: open group  r: rescan  /: filter  esc: back  q: quit"
	if m.active == secSkills && m.chosen[secSkills] != "" {
		help += "  e: nvim"
	}
	footer := statusStyle.Render(help)
	return header + "\n" + body + "\n" + statusStyle.Render(m.notice) + "\n" + footer
}

func (m model) menuView() string {
	accent := lipgloss.NewStyle().Foreground(lipgloss.Color("86"))
	dim := lipgloss.NewStyle().Foreground(lipgloss.Color("245"))
	logo := "    ▄▄     ██\n   ████    ██\n  ██  ██   ██\n ██▀▀▀▀██  ██\n ██    ██  ██"
	var b strings.Builder
	b.WriteString(accent.Bold(true).Render(logo))
	b.WriteString("\n\n" + accent.Bold(true).Render("AI / CONTROL DECK"))
	b.WriteString("\n" + dim.Render("◇ MCP  ───  ◇ SKILLS  ───  ◇ MODELS"))
	b.WriteString("\n\nEnter opens saved results. Only r scans and updates them.\n\n")
	for i, command := range menuCommands {
		label := fmt.Sprintf("  %d  %s", i+1, command.title)
		if i == m.cursor {
			label = activeTabStyle.Render("›" + label[1:])
		} else {
			label = tabStyle.Render(label)
		}
		b.WriteString(label + "\n" + dim.Render("     "+command.desc) + "\n\n")
	}
	b.WriteString(dim.Render("↑/↓ or j/k: select · 1–4: select · enter: open · r: rescan · q: quit"))
	b.WriteString("\n" + dim.Render(m.notice))
	panel := lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).
		BorderForeground(lipgloss.Color("62")).Padding(1, 2).
		Width(min(60, max(1, m.width-8))).Render(b.String())
	return lipgloss.Place(m.width, m.height, lipgloss.Center, lipgloss.Center, panel)
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
