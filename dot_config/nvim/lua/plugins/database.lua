return {
	{
		"tpope/vim-dadbod",
		lazy = true,
		cmd = { "DB" },
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		lazy = true,
		dependencies = {
			"tpope/vim-dadbod",
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		keys = {
			{ "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Database UI" },
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_force_echo_notifications = 1
		end,
	},
}
