package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type theme struct {
	name   string
	colors map[string]string
}
type model struct {
	themes        []theme
	selected      int
	current       string
	root, command string
	width, height int
	message       string
}

func (m model) Init() tea.Cmd { return nil }
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			return m, tea.Quit
		case "up", "k":
			if m.selected > 0 {
				m.selected--
			}
		case "down", "j":
			if m.selected+1 < len(m.themes) {
				m.selected++
			}
		case "enter":
			if len(m.themes) == 0 {
				break
			}
			name := m.themes[m.selected].name
			cmd := exec.Command(m.command, "set", name)
			if out, err := cmd.CombinedOutput(); err != nil {
				m.message = fmt.Sprintf("Apply failed: %s %s", err, strings.TrimSpace(string(out)))
			} else {
				m.current, m.message = name, "Applied "+name
			}
		}
	}
	return m, nil
}
func (m model) View() string {
	if len(m.themes) == 0 {
		return "No theme definitions found.\n"
	}
	leftWidth := m.width / 3
	if leftWidth < 24 {
		leftWidth = 24
	}
	if leftWidth > 34 {
		leftWidth = 34
	}
	list := lipgloss.NewStyle().Width(leftWidth).Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("8")).Padding(0, 1)
	preview := lipgloss.NewStyle().Width(max(0, m.width-leftWidth-6)).Border(lipgloss.RoundedBorder()).BorderForeground(lipgloss.Color("8")).Padding(0, 1)
	var rows []string
	for i, t := range m.themes {
		label := "  " + t.name
		if t.name == m.current {
			label += "  •"
		}
		if i == m.selected {
			label = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("0")).Background(lipgloss.Color("6")).Width(leftWidth - 4).Render("› " + t.name)
		}
		rows = append(rows, label)
	}
	t := m.themes[m.selected]
	var colors []string
	keys := make([]string, 0, len(t.colors))
	for key := range t.colors {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		value := t.colors[key]
		color := lipgloss.Color(value)
		block := lipgloss.NewStyle().Foreground(color).Render("████")
		colors = append(colors, fmt.Sprintf("%s  %-22s %s", block, key, value))
	}
	body := lipgloss.NewStyle().Foreground(lipgloss.Color(t.colors["foreground"])).Background(lipgloss.Color(t.colors["background"])).Padding(1, 2).Render("The quick brown fox\n\nfunc main() {\n  fmt.Println(\"Hello, theme!\")\n}\n\n" + strings.Join(colors, "\n"))
	if m.height > 8 && lipgloss.Height(body) > m.height-6 {
		body = lipgloss.NewStyle().Height(m.height - 6).MaxHeight(m.height - 6).Render(body)
	}
	title := lipgloss.NewStyle().Bold(true).Render("Theme preview: " + t.name)
	right := preview.Render(title + "\n\n" + body)
	content := lipgloss.JoinHorizontal(lipgloss.Top, list.Render(strings.Join(rows, "\n")), right)
	footer := "↑/↓ navigate  enter apply  q quit"
	if m.message != "" {
		footer += "  |  " + m.message
	}
	return lipgloss.NewStyle().Padding(1, 2).Render("theme-sync\n" + content + "\n" + lipgloss.NewStyle().Faint(true).Render(footer))
}
func load(root string) ([]theme, error) {
	files, err := filepath.Glob(filepath.Join(root, "themes", "*.json"))
	if err != nil {
		return nil, err
	}
	var themes []theme
	for _, file := range files {
		data, err := os.ReadFile(file)
		if err != nil {
			return nil, err
		}
		var doc struct {
			Palette map[string]string `json:"palette"`
		}
		if err := json.Unmarshal(data, &doc); err != nil {
			continue
		}
		colors := map[string]string{}
		for key, value := range doc.Palette {
			if strings.HasPrefix(value, "#") {
				colors[key] = value
			}
		}
		name := strings.TrimSuffix(filepath.Base(file), ".json")
		themes = append(themes, theme{name, colors})
	}
	sort.Slice(themes, func(i, j int) bool {
		return strings.ToLower(themes[i].name) < strings.ToLower(themes[j].name)
	})
	return themes, nil
}
func main() {
	root := os.Getenv("THEME_SYNC_ROOT")
	if root == "" {
		root = filepath.Join(os.Getenv("HOME"), ".config", "theme-sync")
	}
	if _, err := os.Stat(filepath.Join(root, "themes")); err != nil {
		exe, _ := os.Executable()
		root = filepath.Clean(filepath.Join(filepath.Dir(exe), "../../../roles/config/.config/theme-sync"))
	}
	themes, err := load(root)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	current := ""
	if b, err := os.ReadFile(filepath.Join(os.Getenv("XDG_STATE_HOME"), "theme-sync", "current")); err == nil {
		current = strings.TrimSpace(string(b))
	} else if b, err := os.ReadFile(filepath.Join(os.Getenv("HOME"), ".local/state/theme-sync/current")); err == nil {
		current = strings.TrimSpace(string(b))
	}
	command := os.Getenv("THEME_SYNC_COMMAND")
	if command == "" {
		command = filepath.Join(os.Getenv("HOME"), "dotfiles/scripts/theme/theme-sync.sh")
	}
	selected := 0
	for i, t := range themes {
		if t.name == current {
			selected = i
			break
		}
	}
	p := tea.NewProgram(model{themes: themes, current: current, root: root, command: command, selected: selected}, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
