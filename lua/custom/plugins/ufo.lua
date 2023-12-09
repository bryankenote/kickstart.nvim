return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    {
      'luukvbaal/statuscol.nvim',
      config = function()
        local builtin = require 'statuscol.builtin'
        require('statuscol').setup {
          relculright = true,
          segments = {
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
            { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            { text = { '%s' }, click = 'v:lua.ScSa' },
          },
        }
      end,
    },
  },
  event = 'VeryLazy',
  opts = {
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  },

  init = function()
    vim.keymap.set('n', 'zR', function()
      require('ufo').openAllFolds()
    end)
    vim.keymap.set('n', 'zM', function()
      require('ufo').closeAllFolds()
    end)
  end,
}
