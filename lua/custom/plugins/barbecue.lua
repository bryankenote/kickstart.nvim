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
    show_modified = true,
    context_follow_icon_color = true,
  },
}
