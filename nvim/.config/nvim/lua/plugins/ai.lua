return {
	{
		"folke/sidekick.nvim",
		cmd = { "Sidekick" },
		keys = {
			{ "<C-.>", mode = { "n", "t", "i", "x" } },
			{ "<leader>a", mode = { "n", "x" } },
		},
		dependencies = {
			"folke/which-key.nvim",
		},
		config = function()
			require("sidekick").setup({
				cli = {
					mux = {
						backend = "tmux",
						enabled = true,
					},
				},
			})

			local wk = require("which-key")
			wk.add({
				{
					"<Tab>",
					function()
						if not require("sidekick").nes_jump_or_apply() then
							return "<Tab>"
						end
					end,
					expr = true,
					desc = "Goto/Apply Next Edit Suggestion",
				},
				{
					"<C-.>",
					function()
						require("sidekick.cli").toggle()
					end,
					desc = "Sidekick Toggle",
					mode = { "n", "t", "i", "x" },
				},
				{ "<leader>a", group = "Sidekick" },
				{
					"<leader>aa",
					function()
						require("sidekick.cli").toggle()
					end,
					desc = "Sidekick Toggle CLI",
				},
				{
					"<leader>as",
					function()
						require("sidekick.cli").select()
					end,
					desc = "Select CLI",
				},
				{
					"<leader>at",
					function()
						require("sidekick.cli").send({ msg = "{this}" })
					end,
					mode = { "x", "n" },
					desc = "Send This",
				},
				{
					"<leader>af",
					function()
						require("sidekick.cli").send({ msg = "{file}" })
					end,
					desc = "Send File",
				},
				{
					"<leader>av",
					function()
						require("sidekick.cli").send({ msg = "{selection}" })
					end,
					mode = { "x" },
					desc = "Send Visual Selection",
				},
				{
					"<leader>ap",
					function()
						require("sidekick.cli").prompt()
					end,
					mode = { "n", "x" },
					desc = "Sidekick Select Prompt",
				},
				{
					"<leader>ac",
					function()
						require("sidekick.cli").toggle({ name = "codex", focus = true })
					end,
					desc = "Sidekick Toggle Codex",
				},
				{
					"<leader>ag",
					function()
						require("sidekick.cli").toggle({ name = "copilot", focus = true })
					end,
					desc = "Sidekick Toggle Copilot",
				},
				-- {
				-- 	"<leader>aG",
				-- 	function()
				-- 		require("sidekick.cli").toggle({ name = "gemini", focus = true })
				-- 	end,
				-- 	desc = "Sidekick Toggle Gemini",
				-- },
				{
					"<leader>ao",
					function()
						require("sidekick.cli").toggle({ name = "opencode", focus = true })
					end,
					desc = "Sidekick Toggle Opencode",
				},
			})
		end,
	},
}
