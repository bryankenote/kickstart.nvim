-- return {
--     "dharmx/track.nvim",
--     config = function()
--         require("track").setup({
--             pickers = {
--                 views = {
--                     path_display = {
--                         absolute = false,
--                         shorten = 100,
--                     },
--                     prompt_prefix = "> ",
--                     wrap_results = true,
--                     layout_strategy = "horizontal",
--                     layout_config = {
--                         prompt_position = "top",
--                         width = 0.95,
--                         height = 0.90,
--                         preview_width = 0.5,
--                     },
--                 },
--             }
--         })
--     end
-- }
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  requires = { { 'nvim-lua/plenary.nvim' } },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED
    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>mm', function()
      harpoon:list():append()
    end, { desc = '[M]ark' })
    vim.keymap.set('n', '<leader>mf', function()
      toggle_telescope(harpoon:list())
    end, { desc = '[F]ind' })
    vim.keymap.set('n', '<leader>ml', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '[L]ist' })

    -- vim.keymap.set('n', '<C-h>', function()
    --   harpoon:list():select(1)
    -- end)
    -- vim.keymap.set('n', '<C-t>', function()
    --   harpoon:list():select(2)
    -- end)
    -- vim.keymap.set('n', '<C-n>', function()
    --   harpoon:list():select(3)
    -- end)
    -- vim.keymap.set('n', '<C-s>', function()
    --   harpoon:list():select(4)
    -- end)
  end,
}
