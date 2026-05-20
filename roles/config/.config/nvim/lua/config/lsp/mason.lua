local M = {}

function M.setup()
	local mason_ok, mason = pcall(require, "mason")
	if not mason_ok then
		return
	end

	mason.setup({
		registries = {
			"github:mason-org/mason-registry",
			"github:Crashdummyy/mason-registry",
		},
	})

	local mlsp_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
	if mlsp_ok then
		mason_lspconfig.setup({
			automatic_enable = false,
			ensure_installed = {
				"lua_ls",
				"ruff",
				"basedpyright",
				"gopls",
				"jsonls",
				"yamlls",
				"dockerls",
				"tailwindcss",
				"bashls",
				"biome",
				"svelte",
				"terraformls",
				"prismals",
				"taplo",
			},
		})
	end

	local mti_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
	if mti_ok then
		mason_tool_installer.setup({
			ensure_installed = {
				"stylua",
				"prettierd",
				"gofumpt",
				"golines",
				"pgformatter",
				"terraform",
				"roslyn",
				"dotenv-linter",
			},
			run_on_start = true,
		})
	end
end

return M
