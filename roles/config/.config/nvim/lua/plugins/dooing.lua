local M = {}

function M.setup()
	require('dooing').setup({
		ui = {
			style = 'modern',
			sections = true,
			priority_bar = true,
			tree_connectors = true,
			note_preview = true,
			progress = true,
			compact_quick_keys = true,
		},
		per_project = {
			enabled = true,
			default_filename = 'dooing.json',
			auto_gitignore = false,
			on_missing = 'prompt',
			auto_open_project_todos = false,
		},
		keymaps = {
			toggle_window = '<leader>td',
			open_project_todo = '<leader>tD',
			show_due_notification = '<leader>tN',
		},
	})
end

return M
