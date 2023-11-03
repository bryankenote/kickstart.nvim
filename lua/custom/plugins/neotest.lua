return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'Issafalcon/neotest-dotnet',
  },
  config = function()
    local neotest = require 'neotest'
    neotest.setup {
      adapters = {
        require 'neotest-dotnet' {
          dap = { justMyCode = false },
        },
      },
    }

    vim.keymap.set('n', '<leader>tn', neotest.run.run, { desc = 'Test Nearest' })
    vim.keymap.set('n', '<leader>tf', [[:lua require('neotest').run.run(vim.fn.expand('%'))<CR>]], { desc = 'Test File', silent = true })
    vim.keymap.set('n', '<leader>td', [[:lua require('neotest').run.run({strategy = "dap"})<CR>]], { desc = 'Debug Nearest', silent = true })
    vim.keymap.set('n', '<leader>ts', neotest.run.stop, { desc = 'Stop test' })
    vim.keymap.set('n', '<leader>to', neotest.output_panel.toggle, { desc = 'Toggle output panel' })
  end,
}
