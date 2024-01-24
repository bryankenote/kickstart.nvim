return {
  'sindrets/diffview.nvim',
  event = 'BufRead',
  dependencies = { 'Mofiqul/vscode.nvim' },
  config = function()
    -- local colors = require('vscode.colors').get_colors()
    -- https://github.com/sindrets/diffview.nvim/issues/241
    vim.cmd [[highlight DiffAdd gui=none guifg=none guibg=#103235]]
    vim.cmd [[highlight DiffChange gui=none guifg=none guibg=#272D43]]
    vim.cmd [[highlight DiffText gui=none guifg=none guibg=#394b70]]
    vim.cmd [[highlight DiffDelete gui=none guifg=none guibg=#3F2D3D]]
    vim.cmd [[highlight DiffviewDiffAddAsDelete guibg=#3f2d3d gui=none guifg=none]]
    vim.cmd [[highlight DiffviewDiffDelete gui=none guifg=#3B4252 guibg=none]]

    -- Left panel
    -- "DiffChange:DiffAddAsDelete",
    -- "DiffText:DiffDeleteText",
    vim.cmd [[highlight DiffAddAsDelete gui=none guifg=none guibg=#3F2D3D]]
    vim.cmd [[highlight DiffDeleteText gui=none guifg=none guibg=#4B1818]]

    -- Right panel
    -- "DiffChange:DiffAdd",
    -- "DiffText:DiffAddText",
    vim.cmd [[highlight DiffAddText gui=none guifg=none guibg=#1C5458]]

    require('diffview').setup {
      enhanced_diff_hl = true,
      hooks = {
        ---@param view StandardView
        view_opened = function(view)
          local utils = require 'utils'
          -- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
          -- the right.
          local function post_layout()
            utils.tbl_ensure(view, 'winopts.diff2.a')
            utils.tbl_ensure(view, 'winopts.diff2.b')
            -- left
            view.winopts.diff2.a = utils.tbl_union_extend(view.winopts.diff2.a, {
              winhl = {
                'DiffChange:DiffAddAsDelete',
                'DiffText:DiffDeleteText',
              },
            })
            -- right
            view.winopts.diff2.b = utils.tbl_union_extend(view.winopts.diff2.b, {
              winhl = {
                'DiffChange:DiffAdd',
                'DiffText:DiffAddText',
              },
            })
          end

          view.emitter:on('post_layout', post_layout)
          post_layout()
        end,
      },
    }
  end,
}
