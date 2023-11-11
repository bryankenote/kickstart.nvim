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
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      local signs = { Error = icons.diagnostics.Error, Warn = icons.diagnostics.Warning, Hint = icons.diagnostics.Hint, Info = icons.diagnostics.Information }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
      vim.diagnostic.config {
        diagnostic = {
          signs = {
            active = signs,
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
        },
      }

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })

      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
      })
    end,
    opts = {},
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local status_cmp_ok, cmp_types = pcall(require, 'cmp.types.cmp')
      local ConfirmBehavior = cmp_types.ConfirmBehavior
      local SelectBehavior = cmp_types.SelectBehavior
      local cmp_window = require 'cmp.config.window'
      local cmp_mapping = require 'cmp.config.mapping'
      local max_width = 0
      local duplicates_default = 0
      local duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      }
      local source_names = {
        nvim_lsp = '(LSP)',
        emoji = '(Emoji)',
        path = '(Path)',
        calc = '(Calc)',
        cmp_tabnine = '(Tabnine)',
        vsnip = '(Snippet)',
        luasnip = '(Snippet)',
        buffer = '(Buffer)',
        tmux = '(TMUX)',
        copilot = '(Copilot)',
        treesitter = '(TreeSitter)',
      }
      local confirm_opts = {
        behavior = ConfirmBehavior.Replace,
        select = false,
      }
      local kind_icons = icons.kind

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      ---when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it is jumpable
      ---@param dir number 1 for forward, -1 for backward; defaults to 1
      ---@return boolean true if a jumpable luasnip field is found while inside a snippet
      local function jumpable(dir)
        local luasnip_ok, luasnip = pcall(require, 'luasnip')
        if not luasnip_ok then
          return false
        end

        local win_get_cursor = vim.api.nvim_win_get_cursor
        local get_current_buf = vim.api.nvim_get_current_buf

        ---sets the current buffer's luasnip to the one nearest the cursor
        ---@return boolean true if a node is found, false otherwise
        local function seek_luasnip_cursor_node()
          -- TODO(kylo252): upstream this
          -- for outdated versions of luasnip
          if not luasnip.session.current_nodes then
            return false
          end

          local node = luasnip.session.current_nodes[get_current_buf()]
          if not node then
            return false
          end

          local snippet = node.parent.snippet
          local exit_node = snippet.insert_nodes[0]

          local pos = win_get_cursor(0)
          pos[1] = pos[1] - 1

          -- exit early if we're past the exit node
          if exit_node then
            local exit_pos_end = exit_node.mark:pos_end()
            if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
              snippet:remove_from_jumplist()
              luasnip.session.current_nodes[get_current_buf()] = nil

              return false
            end
          end

          node = snippet.inner_first:jump_into(1, true)
          while node ~= nil and node.next ~= nil and node ~= snippet do
            local n_next = node.next
            local next_pos = n_next and n_next.mark:pos_begin()
            local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1]) or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

            -- Past unmarked exit node, exit early
            if n_next == nil or n_next == snippet.next then
              snippet:remove_from_jumplist()
              luasnip.session.current_nodes[get_current_buf()] = nil

              return false
            end

            if candidate then
              luasnip.session.current_nodes[get_current_buf()] = node
              return true
            end

            local ok
            ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
            if not ok then
              snippet:remove_from_jumplist()
              luasnip.session.current_nodes[get_current_buf()] = nil

              return false
            end
          end

          -- No candidate, but have an exit node
          if exit_node then
            -- to jump to the exit node, seek to snippet
            luasnip.session.current_nodes[get_current_buf()] = snippet
            return true
          end

          -- No exit node, exit from snippet
          snippet:remove_from_jumplist()
          luasnip.session.current_nodes[get_current_buf()] = nil
          return false
        end

        if dir == -1 then
          return luasnip.in_snippet() and luasnip.jumpable(-1)
        else
          return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
        end
      end

      cmp.setup {
        active = true,
        on_config_done = nil,
        enabled = function()
          local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
          if buftype == 'prompt' then
            return false
          end
          return true
        end,
        confirm_opts = confirm_opts,
        completion = {
          ---@usage The minimum length of a word to complete on.
          keyword_length = 1,
        },
        experimental = {
          ghost_text = false,
          native_menu = false,
        },
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          max_width = max_width,
          kind_icons = kind_icons,
          source_names = source_names,
          duplicates = duplicates,
          duplicates_default = duplicates_default,
          format = function(entry, vim_item)
            if max_width ~= 0 and #vim_item.abbr > max_width then
              vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. icons.ui.Ellipsis
            end
            vim_item.kind = kind_icons[vim_item.kind]

            if entry.source.name == 'copilot' then
              vim_item.kind = icons.git.Octoface
              vim_item.kind_hl_group = 'CmpItemKindCopilot'
            end

            if entry.source.name == 'cmp_tabnine' then
              vim_item.kind = icons.misc.Robot
              vim_item.kind_hl_group = 'CmpItemKindTabnine'
            end

            if entry.source.name == 'crates' then
              vim_item.kind = icons.misc.Package
              vim_item.kind_hl_group = 'CmpItemKindCrate'
            end

            if entry.source.name == 'lab.quick_data' then
              vim_item.kind = icons.misc.CircuitBoard
              vim_item.kind_hl_group = 'CmpItemKindConstant'
            end

            if entry.source.name == 'emoji' then
              vim_item.kind = icons.misc.Smiley
              vim_item.kind_hl_group = 'CmpItemKindEmoji'
            end
            vim_item.menu = source_names[entry.source.name]
            vim_item.dup = duplicates[entry.source.name] or duplicates_default
            return vim_item
          end,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp_window.bordered(),
          documentation = cmp_window.bordered(),
        },
        sources = {
          {
            name = 'copilot',
            -- keyword_length = 0,
            max_item_count = 3,
            trigger_characters = {
              {
                '.',
                ':',
                '(',
                "'",
                '"',
                '[',
                ',',
                '#',
                '*',
                '@',
                '|',
                '=',
                '-',
                '{',
                '/',
                '\\',
                '+',
                '?',
                ' ',
                -- "\t",
                -- "\n",
              },
            },
          },
          {
            name = 'nvim_lsp',
            entry_filter = function(entry, ctx)
              local kind = require('cmp.types.lsp').CompletionItemKind[entry:get_kind()]
              if kind == 'Snippet' and ctx.prev_context.filetype == 'java' then
                return false
              end
              return true
            end,
          },

          { name = 'path' },
          { name = 'luasnip' },
          { name = 'cmp_tabnine' },
          { name = 'nvim_lua' },
          { name = 'buffer' },
          { name = 'calc' },
          { name = 'emoji' },
          { name = 'treesitter' },
          { name = 'crates' },
          { name = 'tmux' },
        },
        mapping = cmp_mapping.preset.insert {
          ['<C-k>'] = cmp_mapping(cmp_mapping.select_prev_item(), { 'i', 'c' }),
          ['<C-j>'] = cmp_mapping(cmp_mapping.select_next_item(), { 'i', 'c' }),
          ['<Down>'] = cmp_mapping(cmp_mapping.select_next_item { behavior = SelectBehavior.Select }, { 'i' }),
          ['<Up>'] = cmp_mapping(cmp_mapping.select_prev_item { behavior = SelectBehavior.Select }, { 'i' }),
          ['<C-d>'] = cmp_mapping.scroll_docs(-4),
          ['<C-f>'] = cmp_mapping.scroll_docs(4),
          ['<C-y>'] = cmp_mapping {
            i = cmp_mapping.confirm { behavior = ConfirmBehavior.Replace, select = false },
            c = function(fallback)
              if cmp.visible() then
                cmp.confirm { behavior = ConfirmBehavior.Replace, select = false }
              else
                fallback()
              end
            end,
          },
          ['<Tab>'] = cmp_mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif jumpable(1) then
              luasnip.jump(1)
            elseif has_words_before() then
              -- cmp.complete()
              fallback()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp_mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-Space>'] = cmp_mapping.complete(),
          ['<C-e>'] = cmp_mapping.abort(),
          ['<CR>'] = cmp_mapping(function(fallback)
            if cmp.visible() then
              local confirm_opts = vim.deepcopy(confirm_opts) -- avoid mutating the original opts below
              local is_insert_mode = function()
                return vim.api.nvim_get_mode().mode:sub(1, 1) == 'i'
              end
              if is_insert_mode() then -- prevent overwriting brackets
                confirm_opts.behavior = ConfirmBehavior.Insert
              end
              local entry = cmp.get_selected_entry()
              local is_copilot = entry and entry.source.name == 'copilot'
              if is_copilot then
                confirm_opts.behavior = ConfirmBehavior.Replace
                confirm_opts.select = true
              end
              if cmp.confirm(confirm_opts) then
                return -- success, exit early
              end
            end
            fallback() -- if not exited early, always fallback
          end),
        },
        cmdline = {
          enable = false,
          options = {
            {
              type = ':',
              sources = {
                { name = 'path' },
                { name = 'cmdline' },
              },
            },
            {
              type = { '/', '?' },
              sources = {
                { name = 'buffer' },
              },
            },
          },
        },
      }
    end,
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = {
          hl = 'GitSignsAdd',
          text = icons.ui.BoldLineLeft,
          numhl = 'GitSignsAddNr',
          linehl = 'GitSignsAddLn',
        },
        change = {
          hl = 'GitSignsChange',
          text = icons.ui.BoldLineLeft,
          numhl = 'GitSignsChangeNr',
          linehl = 'GitSignsChangeLn',
        },
        delete = {
          hl = 'GitSignsDelete',
          text = icons.ui.Triangle,
          numhl = 'GitSignsDeleteNr',
          linehl = 'GitSignsDeleteLn',
        },
        topdelete = {
          hl = 'GitSignsDelete',
          text = icons.ui.Triangle,
          numhl = 'GitSignsDeleteNr',
          linehl = 'GitSignsDeleteLn',
        },
        changedelete = {
          hl = 'GitSignsChange',
          text = icons.ui.BoldLineLeft,
          numhl = 'GitSignsChangeNr',
          linehl = 'GitSignsChangeLn',
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
      yadm = { enable = false },
    },
  },

  {
    'Mofiqul/vscode.nvim',
    config = function()
      require('vscode').setup {
        transparent = true,
      }
      require('vscode').load()
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'vscode',
        component_separators = '|',
        section_separators = '',
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
    branch = '0.1.x',
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
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

-- vim: ts=2 sts=2 sw=2 et
