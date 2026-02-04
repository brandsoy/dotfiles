-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================

-- Register custom filetypes for LSP servers
vim.filetype.add({
	extension = {
		bicep = "bicep",
		bicepparam = "bicep-params",
		tsp = "typespec",
	},
	filename = {
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["compose.yaml"] = "yaml.docker-compose",
		[".gitlab-ci.yml"] = "yaml.gitlab",
		[".gitlab-ci.yaml"] = "yaml.gitlab",
	},
	pattern = {
		["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
		["compose%..*%.ya?ml"] = "yaml.docker-compose",
		[".*/%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		[".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
		[".*/helm.*/values%.ya?ml"] = "yaml.helm-values",
		[".*/charts/.*/values%.ya?ml"] = "yaml.helm-values",
	},
})

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = last_cursor_group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- Large file optimizations
local large_file_group = vim.api.nvim_create_augroup("LargeFile", {})
vim.api.nvim_create_autocmd("BufReadPre", {
	group = large_file_group,
	callback = function(args)
		local file = vim.api.nvim_buf_get_name(args.buf)
		local ok, stat = pcall(vim.uv.fs_stat, file)
		if not ok or not stat then
			return
		end
		if stat.size > 300 * 1024 then
			vim.b.large_file = true
			vim.cmd([[syntax off]])
			pcall(vim.treesitter.stop, args.buf)
			pcall(vim.diagnostic.disable, args.buf)
			vim.opt_local.swapfile = false
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.undolevels = -1
		end
	end,
})

-- Cursorline only in active window
local cursorline_group = vim.api.nvim_create_augroup("ActiveCursorline", {})
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = cursorline_group,
	callback = function()
		vim.wo.cursorline = true
	end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
	group = cursorline_group,
	callback = function()
		vim.wo.cursorline = false
	end,
})

-- -- Ansible filetype detection
-- local ansible_group = vim.api.nvim_create_augroup("AnsibleFileType", {})
-- vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
-- 	group = ansible_group,
-- 	pattern = {
-- 		"*/playbooks/*.{yml,yaml}",
-- 		"*/playbook/*.{yml,yaml}",
-- 		"*/roles/*/tasks/*.{yml,yaml}",
-- 		"*/roles/*/handlers/*.{yml,yaml}",
-- 		"*/roles/*/vars/*.{yml,yaml}",
-- 		"*/roles/*/defaults/*.{yml,yaml}",
-- 		"*/roles/*/meta/*.{yml,yaml}",
-- 		"*/group_vars/*.{yml,yaml}",
-- 		"*/host_vars/*.{yml,yaml}",
-- 		"*/ansible/*.{yml,yaml}",
-- 		"*playbook*.{yml,yaml}",
-- 		"*site.{yml,yaml}",
-- 	},
-- 	callback = function()
-- 		vim.bo.filetype = "yaml.ansible"
-- 	end,
-- })
