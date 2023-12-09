return {
  'kylechui/nvim-surround',
  keys = { 'cs', 'ds', 'ys' },
  config = function()
    require('nvim-surround').setup {
      -- Configuration here, or leave empty to use defaults
    }
  end,
}
