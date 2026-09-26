local M = {}

function M.setup()
	local ok, copilot = pcall(require, "copilot")
	if not ok then
		return
	end

	copilot.setup({
		suggestion = {
			enabled = true,
			auto_trigger = true,
			debounce = 150,
			keymap = {
				accept = "<Tab>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
		},
		panel = { enabled = false },
	})
end

return M
