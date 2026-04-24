-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
-- Treesitter setup (new main branch style)
vim.defer_fn(function()
  -- 1. Install / ensure languages
  local languages = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' }

  for _, lang in ipairs(languages) do
    vim.cmd('TSInstall ' .. lang) -- or handle it more elegantly if you prefer
  end

  local languages = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'markdown' }

  -- List of filetypes that should NEVER try to use Treesitter
  local exclude_filetypes = {
    'TelescopePrompt',
    'TelescopeResults',
    'lazy',
    'mason',
    'help',
    'nofile',
    'quickfix',
    'prompt',
    'alpha',
    'dashboard',
    'NvimTree', -- or "neo-tree", "oil", etc. if you use them
    'spectre_panel',
    'toggleterm',
  }

  -- Safe Treesitter highlighting
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == '' or vim.tbl_contains(exclude_filetypes, ft) then
        return
      end

      -- Silently fail if no parser exists for this filetype
      pcall(vim.treesitter.start, args.buf)
    end,
  })

  -- Safe Treesitter indentation (only for your real languages)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = languages,
    callback = function(args)
      -- No need to check exclude here since pattern is already limited
      pcall(function()
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })

  -- Textobjects setup (now its own module)
  require('nvim-treesitter-textobjects').setup {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
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
      set_jumps = true,
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
  }
end, 0)

-- vim: ts=2 sts=2 sw=2 et
