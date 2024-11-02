return {
  'aznhe21/actions-preview.nvim',
  event = { 'LspAttach' },
  config = function()
    local hl = require 'actions-preview.highlight'
    require('actions-preview').setup {
      diff = {
        algorithm = 'patience',
        ignore_whitespace = true,
      },
      telescope = {
        layout_strategy = 'vertical',
        sorting_strategy = 'ascending',
        layout_config = {
          prompt_position = 'top',
          width = 0.95,
          height = 0.90,
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
      },
      highlight_command = {
        hl.delta '/usr/bin/delta --side-by-side --line-numbers',
      },
    }
  end,
}
