return {
  'aznhe21/actions-preview.nvim',
  config = function()
    require('actions-preview').setup {
      telescope = {
        layout_strategy = 'horizontal',
        sorting_strategy = 'ascending',
        layout_config = {
          prompt_position = 'top',
          width = 0.95,
          height = 0.90,
          preview_width = 0.5,
        },
      },
    }
  end,
}
