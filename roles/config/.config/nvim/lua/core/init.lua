-- Load core configuration modules
require("core.globals")
require('core.filetypes').setup()

-- Local shim to silence deprecation notice for vim.tbl_flatten (Neovim 0.11+) used by some plugins.
-- Re-implements flattening in Lua so the deprecated builtin isn't invoked.
if vim.tbl_flatten then
	vim.tbl_flatten = function(list)
		local ret = {}
		local function _flatten(l)
			for _, v in ipairs(l) do
				if type(v) == "table" then
					_flatten(v)
				else
					ret[#ret + 1] = v
				end
			end
		end
		_flatten(list)
		return ret
	end
end

require("core.options").setup()

pcall(function()
	if vim.fn.has("nvim-0.12") == 1 then
		require("vim._core.ui2").enable({
			enable = true,
			msg = { targets = "msg" },
		})
	end
end)

require("core.statusline").setup()
require("core.keymaps").setup()
require("core.autocmds").setup()
