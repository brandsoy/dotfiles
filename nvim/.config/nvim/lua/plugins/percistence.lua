-- In your plugin config (e.g., lazy.nvim)
return {
  'folke/persistence.nvim',
  opts = {
    options = { 'localoptions' }, -- Saves buffer-specific settings like spelllang
  },
}
