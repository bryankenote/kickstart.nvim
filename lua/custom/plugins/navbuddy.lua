return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'SmiteshP/nvim-navbuddy',
      dependencies = {
        'SmiteshP/nvim-navic',
        'MunifTanjim/nui.nvim',
      },
      opts = {
        window = {
          size = {
            width = '95%',
            height = '90%',
          },
          sections = {
            left = {
              size = '15%',
            },
            mid = {
              size = '25%',
            },
            right = {
              preview = 'always',
            },
          },
        },
        lsp = {
          auto_attach = true,
        },
      },
    },
  },
  -- your lsp config or other stuff
}
