return {
  'petertriho/nvim-scrollbar',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('scrollbar.handlers.gitsigns').setup()

    require('scrollbar').setup {
      handlers = {
        cursor = false,
      },
      handle = {
        color = '#595959',
      },
    }
  end,
}
