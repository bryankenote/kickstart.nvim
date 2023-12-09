return {
  'utilyre/barbecue.nvim',
  name = 'barbecue',
  version = '*',
  event = { 'LspAttach' },
  dependencies = {
    'SmiteshP/nvim-navic',
    'nvim-tree/nvim-web-devicons', -- optional dependency
  },
  opts = {
    -- configurations go here
  },
}
