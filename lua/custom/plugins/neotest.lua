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

    vim.keymap.set('n', '<leader>tn', neotest.run.run, { desc = '[N]earest' })
    vim.keymap.set('n', '<leader>tf', [[:lua require('neotest').run.run(vim.fn.expand('%'))<CR>]], { desc = '[F]ile', silent = true })
    vim.keymap.set('n', '<leader>td', [[:lua require('neotest').run.run({strategy = "dap"})<CR>]], { desc = '[D]ebug Nearest', silent = true })
    vim.keymap.set('n', '<leader>ts', neotest.run.stop, { desc = '[S]top test' })
    vim.keymap.set('n', '<leader>to', neotest.output_panel.toggle, { desc = 'Toggle [o]utput panel' })
  end,
}
