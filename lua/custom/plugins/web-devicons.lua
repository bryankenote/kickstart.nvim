local icons = require 'custom/icons'
return {
  'nvim-tree/nvim-web-devicons',
  opts = {
    override_by_extension = {
      ['fsd'] = {
        icon = icons.ui.BoldGear,
        color = '#555555',
        cterm_color = '240',
        name = 'FSD',
      },
    },
  },
}
