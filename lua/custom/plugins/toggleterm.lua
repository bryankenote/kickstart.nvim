return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      open_mapping = '<C-b>',
      direction = 'float',
      size = 40,
      start_in_insert = true,
    }
  end,
}
