-- [[ Setup lazy plugin manager ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
local icons = require 'icons'
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', opts = { ui = { border = 'rounded' } } },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      vim.diagnostic.config {
        signs = {
          -- Modern way: severity-keyed icons (this replaces your old loop)
          text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warning,
            [vim.diagnostic.severity.INFO]  = icons.diagnostics.Information,
            [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
          },
          -- Optional: if you want line number highlighting (equivalent to your old numhl = hl)
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
          },
          -- You could add linehl here too if you ever want full-line highlighting
        },
        virtual_text = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      }

      -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      --   border = 'rounded',
      -- })

      -- vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      --   border = 'rounded',
      -- })

      require('lspconfig.ui.windows').default_options.border = 'rounded'
    end,
    opts = {},
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter' },
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {}, event = { 'VeryLazy' } },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = {
          -- hl = 'GitSignsAdd',
          text = icons.ui.BoldLineLeft,
          -- numhl = 'GitSignsAddNr',
          -- linehl = 'GitSignsAddLn',
        },
        change = {
          -- hl = 'GitSignsChange',
          text = icons.ui.BoldLineLeft,
          -- numhl = 'GitSignsChangeNr',
          -- linehl = 'GitSignsChangeLn',
        },
        delete = {
          -- hl = 'GitSignsDelete',
          text = icons.ui.Triangle,
          -- numhl = 'GitSignsDeleteNr',
          -- linehl = 'GitSignsDeleteLn',
        },
        topdelete = {
          -- hl = 'GitSignsDelete',
          text = icons.ui.Triangle,
          -- numhl = 'GitSignsDeleteNr',
          -- linehl = 'GitSignsDeleteLn',
        },
        changedelete = {
          -- hl = 'GitSignsChange',
          text = icons.ui.BoldLineLeft,
          -- numhl = 'GitSignsChangeNr',
          -- linehl = 'GitSignsChangeLn',
        },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
      sign_priority = 6,
      status_formatter = nil, -- Use default
      update_debounce = 200,
      max_file_length = 40000,
      preview_config = {
        -- Options passed to nvim_open_win
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    },
  },

  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        -- transparent = true,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = 'none',
                float = {
                  bg = 'none',
                },
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            NormalFloat = { bg = 'none' },
            FloatBorder = { bg = 'none' },
            FloatTitle = { bg = 'none' },
            -- Save an hlgroup with dark background and dimmed foreground
            -- so that you can use it where your still want darker windows.
            -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
            NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
            -- Popular plugins that open floats will link to NormalFloat by default;
            -- set their background accordingly if you wish to keep them dark and borderless
            LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
            MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          }
        end,
      }
      -- vim.cmd 'colorscheme kanagawa-wave'
    end,
  },

  {
    'bluz71/vim-nightfly-colors',
    name = 'nightfly',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nightflyNormalFloat = true
    end,
  },

  {
    'olimorris/onedarkpro.nvim',
    name = 'onedarkpro',
    lazy = false,
    priority = 1000,
  },

  {
    'rose-pine/neovim',
    name = 'rosepine',
    lazy = false,
    priority = 1000,
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
  },

  {
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
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('ibl').setup {
        exclude = {
          buftypes = { 'terminal', 'nofile' },
          filetypes = {
            'help',
            'startify',
            'dashboard',
            'lazy',
            'neogitstatus',
            'NvimTree',
            'Trouble',
            'text',
          },
        },
        indent = {
          char = icons.ui.LineLeft,
          tab_char = icons.ui.LineLeft,
        },
        whitespace = {
          remove_blankline_trail = true,
        },
        scope = {
          show_start = false,
          show_end = false,
        },
      }
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, { ui = { border = 'rounded' } })

-- vim: ts=2 sts=2 sw=2 et
