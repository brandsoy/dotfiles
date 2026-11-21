-- Rex provides this global when it loads the config.
---@diagnostic disable-next-line: undefined-global
local rex = rex

-- Match the prefix in roles/tmux/.tmux.conf.
local prefix = "ctrl+s>"

rex.bind(prefix .. "ctrl+s", "pane.send_key", { key = "ctrl+s" })
rex.bind(prefix .. "r", "client.config.reload")

rex.bind(prefix .. "c", "client.tab.new")
rex.bind(prefix .. "n", "client.tab.next")
rex.bind(prefix .. "p", "client.tab.previous")
for index = 1, 9 do
	rex.bind(prefix .. index, "client.tab.goto", { index = index })
end

-- Rex matches unshifted keys: on a US layout, these produce % and ".
rex.bind(prefix .. "shift+5", "pane.split.right")
rex.bind(prefix .. "shift+'", "pane.split.down")
rex.bind(prefix .. "z", "pane.zoom")

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	rex.bind(prefix .. key, "pane.focus." .. direction)
	rex.bind(prefix .. "shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
end

-- Use Rex's pickers and session history for the sesh and tmux workflows.
rex.bind(prefix .. "s", "session.switch")
rex.bind(prefix .. "shift+s", "session.switch")
rex.bind(prefix .. "a", "session.recent")
rex.bind(prefix .. "shift+a", "pane.view_activity")
rex.bind(prefix .. "shift+w", "pane.go_to")

-- Rex copy mode already uses v, Ctrl+v, y, and Enter.
rex.bind(prefix .. "[", "pane.copy_mode.enter")
