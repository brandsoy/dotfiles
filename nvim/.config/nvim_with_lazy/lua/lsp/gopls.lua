local M = {}

-- Simple gopls config with just the essentials
M.settings = {
	gopls = {
		staticcheck = true,
		usePlaceholders = true,
		completeUnimported = true,
		verboseOutput = false,
	}
}

return M
