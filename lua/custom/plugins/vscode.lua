return {
  'Mofiqul/vscode.nvim',
  priority = 1000,
  config = function()
    local c = require('vscode.colors').get_colors()
    require('vscode').setup {
      style = 'dark',
      transparent = false,
      italic_comments = true,
      disable_nvimtree_bg = true,
      group_overrides = {
        NormalFloat = { fg = c.vscFront, bg = 'NONE' },
        FloatBorder = { fg = c.vscLineNumber, bg = 'NONE' },
        -- GitGutterChange = { fg = c.vscMediumBlue, bg = 'NONE' },
        -- GitSignsChange = { fg = c.vscMediumBlue, bg = 'NONE' },
        Comment = { fg = c.vscGray, bg = 'NONE', italic = true },
        -- SpecialComment = { fg = c.vscGray, bg = 'NONE', italic = true },
        -- ['@comment'] = { fg = c.vscGray, bg = 'NONE', italic = true },
      },
    }
    require('vscode').load()
  end,
}
