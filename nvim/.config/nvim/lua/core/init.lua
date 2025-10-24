-- Load core configuration modules
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

require("core.options")
require("core.keymaps")
require("core.autocmds")
