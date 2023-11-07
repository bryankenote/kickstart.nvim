return {
  'nvim-tree/nvim-tree.lua',
  config = function(bufnr)
    local setup, nvimtree = pcall(require, 'nvim-tree')
    if not setup then
      return
    end

    local function on_attach(bufnr)
      local api = require 'nvim-tree.api'

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.set('n', 'l', api.node.open.edit, opts 'Open')
      vim.keymap.set('n', 'o', api.node.open.edit, opts 'Open')
      vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
      vim.keymap.set('n', 'v', api.node.open.vertical, opts 'Open: Vertical Split')
      vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts 'Close Directory')
      vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts 'CD')
    end

    -- local keymap = vim.keymap -- for conciseness
    vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = '[E]xplorer' }) -- toggle file explorer

    -- vim.opt.foldmethod = "expr"
    -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    -- vim.opt.foldenable = false --                  " Disable folding at startup.

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    vim.opt.termguicolors = true

    local HEIGHT_RATIO = 0.8 -- You can change this
    local WIDTH_RATIO = 0.5 -- You can change this too

    local icons = require 'icons'
    local use_icons = true

    nvimtree.setup {
      on_attach = on_attach,
      disable_netrw = true,
      hijack_netrw = true,
      respect_buf_cwd = true,
      sync_root_with_cwd = true,
      view = {
        relativenumber = true,
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * WIDTH_RATIO
            local window_h = screen_h * HEIGHT_RATIO
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = 'rounded',
              relative = 'editor',
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
        width = function()
          return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
        end,
      },
      -- filters = {
      --   custom = { "^.git$" },
      -- },
      -- renderer = {
      --   indent_width = 1,
      -- },
      --
      auto_reload_on_write = false,
      hijack_cursor = false,
      hijack_unnamed_buffer_when_opening = false,
      sort_by = 'name',
      root_dirs = {},
      prefer_startup_root = false,
      reload_on_bufenter = false,
      select_prompts = false,
      renderer = {
        add_trailing = false,
        group_empty = false,
        highlight_git = true,
        full_name = false,
        highlight_opened_files = 'none',
        root_folder_label = ':t',
        indent_width = 2,
        indent_markers = {
          enable = false,
          inline_arrows = true,
          icons = {
            corner = '└',
            edge = '│',
            item = '│',
            none = ' ',
          },
        },
        icons = {
          webdev_colors = use_icons,
          git_placement = 'before',
          padding = ' ',
          symlink_arrow = ' ➛ ',
          show = {
            file = use_icons,
            folder = use_icons,
            folder_arrow = use_icons,
            git = use_icons,
          },
          glyphs = {
            default = icons.ui.Text,
            symlink = icons.ui.FileSymlink,
            bookmark = icons.ui.BookMark,
            folder = {
              arrow_closed = icons.ui.TriangleShortArrowRight,
              arrow_open = icons.ui.TriangleShortArrowDown,
              default = icons.ui.Folder,
              open = icons.ui.FolderOpen,
              empty = icons.ui.EmptyFolder,
              empty_open = icons.ui.EmptyFolderOpen,
              symlink = icons.ui.FolderSymlink,
              symlink_open = icons.ui.FolderOpen,
            },
            git = {
              unstaged = icons.git.FileUnstaged,
              staged = icons.git.FileStaged,
              unmerged = icons.git.FileUnmerged,
              renamed = icons.git.FileRenamed,
              untracked = icons.git.FileUntracked,
              deleted = icons.git.FileDeleted,
              ignored = icons.git.FileIgnored,
            },
          },
        },
        special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md' },
        symlink_destination = true,
      },
      hijack_directories = {
        enable = false,
        auto_open = true,
      },
      update_focused_file = {
        enable = true,
        debounce_delay = 15,
        update_root = true,
        ignore_list = {},
      },
      diagnostics = {
        enable = use_icons,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          hint = icons.diagnostics.BoldHint,
          info = icons.diagnostics.BoldInformation,
          warning = icons.diagnostics.BoldWarning,
          error = icons.diagnostics.BoldError,
        },
      },
      filters = {
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        custom = { 'node_modules', '\\.cache' },
        exclude = {},
      },
      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = {},
      },
      git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
        timeout = 200,
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = true,
          global = false,
          restrict_above_cwd = false,
        },
        expand_all = {
          max_folder_discovery = 300,
          exclude = {},
        },
        file_popup = {
          open_win_config = {
            col = 1,
            row = 1,
            relative = 'cursor',
            border = 'shadow',
            style = 'minimal',
          },
        },
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            picker = 'default',
            chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
            exclude = {
              filetype = { 'notify', 'lazy', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
              buftype = { 'nofile', 'terminal', 'help' },
            },
          },
        },
        remove_file = {
          close_window = true,
        },
      },
      trash = {
        cmd = 'trash',
        require_confirm = true,
      },
      live_filter = {
        prefix = '[FILTER]: ',
        always_show_folders = true,
      },
      tab = {
        sync = {
          open = false,
          close = false,
          ignore = {},
        },
      },
      notify = {
        threshold = vim.log.levels.INFO,
      },
      log = {
        enable = false,
        truncate = false,
        types = {
          all = false,
          config = false,
          copy_paste = false,
          dev = false,
          diagnostics = false,
          git = false,
          profile = false,
          watcher = false,
        },
      },
      system_open = {
        cmd = nil,
        args = {},
      },
    }
  end,
}
