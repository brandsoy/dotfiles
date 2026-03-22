local M = {}

local themes = {
  {
    name = "oc-2",
    plugin = "oc-2.nvim",
    before = function(theme)
      require("oc2").setup({ theme = theme.name })
    end,
  },
  {
    name = "oc-2-noir",
    plugin = "oc-2.nvim",
    before = function(theme)
      require("oc2").setup({ theme = theme.name })
    end,
  },
  { name = "koda", plugin = "koda.nvim" },
  { name = "tokyonight-night", plugin = "tokyonight.nvim" },
  { name = "catppuccin", plugin = "catppuccin" },
  { name = "github_dark_tritanopia", plugin = "github-theme" },
  { name = "rose-pine", plugin = "rose-pine" },
  { name = "alabaster", plugin = "alabaster" },
  { name = "zenwritten", plugin = "zenbones" },
  { name = "onedark", plugin = "onedark" },
}

local theme_names = {}
local theme_lookup = {}
local state_file = vim.fn.stdpath("state") .. "/theme.txt"

for _, theme in ipairs(themes) do
  theme_names[#theme_names + 1] = theme.name
  theme_lookup[theme.name] = theme
end

local function notify(message, level)
  if vim.notify then
    vim.notify(message, level or vim.log.levels.INFO, { title = "Theme" })
  end
end

local function save_theme(name)
  local state_dir = vim.fn.fnamemodify(state_file, ":h")
  if vim.fn.isdirectory(state_dir) == 0 then
    vim.fn.mkdir(state_dir, "p")
  end

  vim.fn.writefile({ name }, state_file)
end

local function read_saved_theme()
  if vim.fn.filereadable(state_file) ~= 1 then
    return nil
  end

  local lines = vim.fn.readfile(state_file)
  local name = lines[1]

  if name and theme_lookup[name] then
    return name
  end

  return nil
end

local function current_index()
  local current = vim.g.colors_name or themes[1].name

  for index, theme in ipairs(themes) do
    if theme.name == current then
      return index
    end
  end

  return 1
end

function M.list()
  return vim.deepcopy(theme_names)
end

function M.saved()
  return read_saved_theme()
end

function M.apply(name, opts)
  opts = opts or {}

  local theme = theme_lookup[name]
  if not theme then
    notify(string.format("Unknown theme: %s", name), vim.log.levels.ERROR)
    return false
  end

  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    lazy.load({ plugins = { theme.plugin } })
  end

  if theme.before then
    theme.before(theme)
  end

  local ok_colorscheme, err = pcall(vim.cmd.colorscheme, theme.name)
  if not ok_colorscheme then
    notify(string.format("Failed to load %s: %s", theme.name, err), vim.log.levels.ERROR)
    return false
  end

  if not opts.silent then
    notify(string.format("Switched to %s", theme.name))
  end

  if opts.persist ~= false then
    save_theme(theme.name)
  end

  return true
end

function M.cycle(step)
  local next_index = current_index() + step

  if next_index < 1 then
    next_index = #themes
  elseif next_index > #themes then
    next_index = 1
  end

  return M.apply(themes[next_index].name)
end

function M.select()
  vim.ui.select(theme_names, {
    prompt = "Select colorscheme",
    format_item = function(item)
      if item == vim.g.colors_name then
        return item .. " (active)"
      end

      return item
    end,
  }, function(choice)
    if choice then
      M.apply(choice)
    end
  end)
end

function M.setup()
  if vim.g.theme_commands_loaded then
    return
  end

  vim.g.theme_commands_loaded = true

  vim.api.nvim_create_user_command("Theme", function(command_opts)
    if command_opts.args ~= "" then
      M.apply(command_opts.args)
      return
    end

    M.select()
  end, {
    nargs = "?",
    complete = function(arg_lead)
      return vim.tbl_filter(function(name)
        return name:find(arg_lead, 1, true) == 1
      end, theme_names)
    end,
    desc = "Pick or set colorscheme",
  })

  vim.api.nvim_create_user_command("ThemeNext", function()
    M.cycle(1)
  end, { desc = "Switch to next colorscheme" })

  vim.api.nvim_create_user_command("ThemePrev", function()
    M.cycle(-1)
  end, { desc = "Switch to previous colorscheme" })
end

function M.startup(default_name)
  return M.apply(read_saved_theme() or default_name or themes[1].name, {
    silent = true,
    persist = false,
  })
end

return M
