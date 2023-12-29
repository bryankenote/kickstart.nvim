return {
  'echasnovski/mini.indentscope',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    symbol = '▎',
    options = {
      indent_at_cursor = false,
      try_as_border = true,
    },
    draw = {
      animation = function()
        return 0
      end,
    },
  },
}
