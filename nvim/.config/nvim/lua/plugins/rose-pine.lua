-- lua/plugins/rose-pine.lua
return {
  'Shatur/neovim-ayu',
  name = 'ayu',
  -- 'rose-pine/neovim',
  -- name = 'rose-pine',
  config = function()
    -- vim.cmd 'colorscheme rose-pine'
    vim.cmd 'colorscheme ayu'
  end,
}
