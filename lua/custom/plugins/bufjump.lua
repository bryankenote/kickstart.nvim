return {
  'kwkarlwang/bufjump.nvim',
  config = function()
    require('bufjump').setup {
      forward = '<C-n>',
      backward = '<C-p>',
      on_success = nil,
    }
  end,
}
