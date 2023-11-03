--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.diffopt:append { 'filler', 'context:9999', 'iwhite' }

local icons = require 'custom.icons'

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
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
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      -- 'hrsh7th/cmp-cmdline',

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
  { 'hrsh7th/cmp-nvim-lsp', lazy = true },
  { 'saadparwaiz1/cmp_luasnip', lazy = true },
  { 'hrsh7th/cmp-buffer', lazy = true },
  { 'hrsh7th/cmp-path', lazy = true },
  -- { 'hrsh7th/cmp-cmdline', lazy = true },

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

  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'onedark'
  --   end,
  -- },

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
      }
    end,
    opts = {},
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

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.so = 16
-- vim.opt.list = true
-- vim.opt.listchars:append("trail:·")
-- vim.opt.listchars:append("lead:·")
vim.opt.fillchars = { eob = ' ' }

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- vim.keymap.set('n', '<C-w>e', '<cmd>vsplit<cr>', { silent = true })
-- vim.keymap.set('n', '<C-w>o', '<cmd>split<cr>', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>M', { silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>M', { silent = true })

vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.keymap.set('n', '<C-Up>', '<cmd>resize -2<cr>')
vim.keymap.set('n', '<C-Down>', '<cmd>resize +2<cr>')
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>')
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>')

-- vscode style move lines
-- vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==')
-- vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==')
-- vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv-gv")
-- vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv-gv")

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local _actions = require 'telescope.actions'
local _persisted_actions = require 'telescope._extensions.persisted.actions'
require('telescope').setup {
  defaults = {
    wrap_results = true,
    layout_strategy = 'horizontal',
    layout_config = {
      prompt_position = 'top',
      width = 0.95,
      height = 0.90,
      preview_width = 0.5,
    },
    sorting_strategy = 'ascending',
    file_ignore_patterns = { '%.g%.cs$' },
    keymaps = {},
  },
  pickers = {
    lsp_references = {
      show_line = false,
    },
    lsp_definitions = {
      show_line = false,
    },
    lsp_implementations = {
      show_line = false,
    },
    buffers = {
      mappings = {
        n = {
          ['dd'] = _actions.delete_buffer,
        },
      },
    },
  },
  -- extensions = {
  --   persisted = {
  --     mappings = {
  --       n = {
  --         ['dd'] = _persisted_actions.delete_session,
  --       },
  --     },
  --   },
  -- },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'persisted')

-- See `:help telescope.builtin`
-- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
-- vim.keymap.set('n', '<leader>f', function()
--   -- You can pass additional configuration to telescope to change theme, layout, etc.
--   require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
--     winblend = 10,
--     previewer = false,
--   })
-- end, { desc = '[F]ind in current buffer' })

vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[S]earch in current [B]uffer' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').live_grep, { desc = '[S]earch [T]ext' })
vim.keymap.set('n', '<leader><tab>', '<cmd>Telescope telescope-tabs list_tabs initial_mode=insert<cr>', { desc = '[S]earch [T]abs' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sl', require('telescope.builtin').resume, { desc = '[S]earch resume [L]ast' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').oldfiles, { desc = '[S]earch [R]ecent' })
vim.keymap.set('n', '<leader>sR', require('telescope.builtin').registers, { desc = '[S]earch [R]egisters' })
vim.keymap.set('n', '<leader>sC', require('telescope.builtin').commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })

vim.keymap.set('n', '<leader>gj', "<cmd>lua require 'gitsigns'.next_hunk({ navigation_message = false })<cr>", { desc = 'Next Hunk' })
vim.keymap.set('n', '<leader>gk', "<cmd>lua require 'gitsigns'.prev_hunk({ navigation_message = false })<cr>", { desc = 'Prev Hunk' })
vim.keymap.set('n', '<leader>gl', require('gitsigns').blame_line, { desc = '[B]lame' })
vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { desc = '[P]review' })
vim.keymap.set('n', '<leader>gr', require('gitsigns').reset_hunk, { desc = '[R]eset hunk' })
vim.keymap.set('n', '<leader>gR', require('gitsigns').reset_buffer, { desc = '[R]eset buffer' })
vim.keymap.set('n', '<leader>gs', require('gitsigns').stage_hunk, { desc = '[S]tage hunk' })
vim.keymap.set('n', '<leader>go', require('telescope.builtin').git_status, { desc = '[O]pen changed file' })

vim.keymap.set('n', '<leader>gtb', require('telescope.builtin').git_branches, { desc = 'Checkout [B]ranches' })
vim.keymap.set('n', '<leader>gtc', require('telescope.builtin').git_bcommits, { desc = 'Checkout buffer [c]ommit' })
vim.keymap.set('n', '<leader>gtC', require('telescope.builtin').git_commits, { desc = 'Checkout any [C]ommit' })
--vim.keymap.set('v', '<leader>gtr', require('telescope.builtin').git_bcommits_range, { desc = 'Checkout buffer commit in [R]ange' })
vim.keymap.set('n', '<leader>gta', require('telescope.builtin').git_stash, { desc = '[A]pply stash' })

-- vim.keymap.set('n', '<leader>bd', function()
--   local bufferId = vim.api.nvim_get_current_buf()
--   vim.cmd("<cmd>lua require('bufjump').backward()<cr>")
--   vim.cmd('<cmd>bd<cr>')
-- end, { desc = '[D]rop' })

vim.keymap.set('n', '<leader>bd', '<cmd>bp<bar>sp<bar>bn<bar>bd<cr>', { desc = '[D]rop' })
vim.keymap.set('n', '<leader>bf', require('telescope.builtin').buffers, { desc = '[F]ind' })
vim.keymap.set('n', '<leader>be', '<cmd>vsplit<cr>', { desc = 'V[e]rtical split' })
vim.keymap.set('n', '<leader>bo', '<cmd>split<cr>', { desc = 'H[o]rizontal split' })
vim.keymap.set('n', '<leader>bs', '<cmd>SessionSave<cr>', { desc = '[S]ave session' })
vim.keymap.set('n', '<leader>br', '<cmd>Telescope persisted<cr>', { desc = '[R]estore session' })

vim.keymap.set('n', '<leader>ml', '<cmd>Track<cr>', { desc = '[L]ist' })
vim.keymap.set('n', '<leader>mm', '<cmd>TrackMark<cr>', { desc = '[M]ark' })

vim.keymap.set('n', '<leader>Do', '<cmd>DiffviewOpen<cr>', { desc = 'Open' })
vim.keymap.set('n', '<leader>Dc', '<cmd>DiffviewClose<cr>', { desc = 'Close' })

vim.keymap.set('n', '<leader>l>', '<cmd>LspStart<cr>', { desc = 'Enable lsp' })
vim.keymap.set('n', '<leader>l<', '<cmd>LspStop<cr>', { desc = 'Disable lsp' })

vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<cr>', { desc = 'Zen mode' })

vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = '[W]rite file' })
vim.keymap.set('n', '<leader>q', '<cmd>confirm q<cr>', { desc = '[Q]uit' })

vim.keymap.set('n', '<leader>/', '<Plug>(comment_toggle_linewise_current)', { desc = 'Comment toggle line' })
vim.keymap.set('v', '<leader>/', '<Plug>(comment_toggle_linewise_visual)', { desc = 'Comment toggle lines' })

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })

    if client.server_capabilities.signatureHelpProvider then
      require('lsp-overloads').setup(client, {})
    end
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>la', vim.lsp.buf.code_action, 'Code [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  -- nmap('<leader>lD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ls', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
  nmap('<leader>ld', "<cmd>lua require 'telescope.builtin'.diagnostics({ bufnr = 0 })<cr>", 'Document [D]iagnostics')
  nmap('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[S]ymbols')
  nmap('<leader>lwd', require('telescope.builtin').diagnostics, '[D]iagnostics')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('J', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>lwm', vim.lsp.buf.add_workspace_folder, '[M]ake Folder')
  nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, '[R]emove Folder')
  nmap('<leader>lwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local which_key = require 'which-key'

which_key.setup {
  plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true,
      suggestions = 20,
    }, -- use which-key for spelling hints
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ...
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = false, -- default bindings on <c-w>
      nav = false, -- misc bindings to work with windows
      z = false, -- bindings for folds, spelling and others prefixed with z
      g = false, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  operators = { gc = 'Comments' },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
    separator = icons.ui.BoldArrowRight, -- symbol used between a key and it's label
    group = icons.ui.Plus, -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = '<c-d>', -- binding to scroll down inside the popup
    scroll_up = '<c-u>', -- binding to scroll up inside the popup
  },
  window = {
    border = 'single', -- none, single, double, shadow
    position = 'bottom', -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    winblend = 0,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = 'left', -- align columns left, center or right
  },
  hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' }, -- hide mapping boilerplate
  show_help = true, -- show help message on the command line when the popup is visible
  show_keys = true, -- show the currently pressed key and its label as a message in the command line
  triggers = 'auto', -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { 'j', 'k' },
    v = { 'j', 'k' },
  },
  -- disable the WhichKey popup for certain buf types and file types.
  -- Disabled by default for Telescope
  disable = {
    buftypes = {},
    filetypes = { 'TelescopePrompt' },
  },
}

-- document existing key chains
which_key.register {
  -- ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  -- ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  -- ['<leader>d'] = { name = '[D]ebug', _ = 'which_key_ignore' },
  ['<leader>D'] = { name = '[D]iffview', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>l'] = { name = '[L]sp', _ = 'which_key_ignore' },
  ['<leader>lw'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  ['<leader>m'] = { name = '[M]arks', _ = 'which_key_ignore' },
  -- ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
