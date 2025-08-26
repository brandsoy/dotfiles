-- ~/.config/nvim/lua/user/checkbox.lua
local M = {}

function M.toggle()
  local line = vim.api.nvim_get_current_line()
  local new_line = line
  local timestamp_pattern = ' @ %d%d%d%d%-%d%d%-%d%d %d%d:%d%d$'
  local timestamp = os.date ' @ %Y-%m-%d %H:%M'

  if line:match '%[ %]' then
    -- Mark as done: replace [ ] with [x] and add timestamp if not present
    new_line = line:gsub('%[ %]', '[x]')
    if not new_line:match(timestamp_pattern) then
      new_line = new_line .. timestamp
    end
  elseif line:match '%[x%]' then
    -- Unmark done: replace [x] with [ ] and remove timestamp if present
    new_line = line:gsub('%[x%]', '[ ]')
    new_line = new_line:gsub(timestamp_pattern, '')
  end

  if new_line ~= line then
    vim.api.nvim_set_current_line(new_line)
  end
end

return M
