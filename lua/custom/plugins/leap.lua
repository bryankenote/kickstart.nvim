return {
  'ggandor/leap.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    require('leap').add_default_mappings()

    -- vim.keymap.set('n', 's', function()
    --   -- Searching in all windows (including the current one) on the tab page.
    --   require('leap').leap {
    --     target_windows = vim.tbl_filter(function(win)
    --       return vim.api.nvim_win_get_config(win).focusable
    --     end, vim.api.nvim_tabpage_list_wins(0)),
    --   }
    -- end)
    -- vim.keymap.set('v', 's', function()
    --   -- Bidirectional search in the current window is just a specific case of the
    --   -- multi-window mode.
    --   require('leap').leap { target_windows = { vim.fn.win_getid() } }
    -- end)

    -- require 'leap'
    -- vim.keymap.set('n', '<leader>f', '<Plug>(leap-forward-to)', { desc = 'Leap forward' })
    -- vim.keymap.set('n', '<leader>F', '<Plug>(leap-backward-to)', { desc = 'Leap backward' })
    -- vim.keymap.set('v', '<leader>f', '<Plug>(leap-forward-till)', { desc = 'Move selection forward' })
    -- vim.keymap.set('v', '<leader>F', '<Plug>(leap-backward-till)', { desc = 'Move selection backward' })
  end,
}
