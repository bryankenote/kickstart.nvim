return {
  'petertriho/nvim-scrollbar',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local colors = require('vscode.colors').get_colors()
    require('scrollbar.handlers.gitsigns').setup()

    require('scrollbar').setup {
      handlers = {
        handle = true,
        cursor = false,
        search = true,
        gitsigns = true,
        diagnostic = true,
      },
      handle = {
        color = '#595959',
      },
      marks = {
        search = { color = colors.vscYellow },
      },
    }
  end,
}
