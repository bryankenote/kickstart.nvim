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

-- Install lazy plugin manager
require 'lazy-bootstrap'

-- Setup lazy plugin manager - configure plugins
require 'core-plugins'

-- Configure which-key (keymap previewer)
require 'which-key-setup'

-- Set options
require 'options'

-- Configure keymaps
require 'keymaps'

-- Configure Telescope (fuzzy finder)
require 'telescope-setup'

-- Configure Treesitter (syntax parser for highlighting)
require 'treesitter-setup'

-- Configure LSP (Language Server Protocol)
require 'lsp-setup'

-- Configure CMP (completion)
require 'cmp-setup'

require 'filetypes'

require 'autocmds'

---@class parser_config
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.facility = {
  install_info = {
    url = '~/parsers/tree-sitter-facility', -- local path or git repo
    files = { 'src/parser.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
    -- optional entries:
    branch = 'events', -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
  },
  filetype = 'fsd', -- if filetype does not match the parser name
}
vim.treesitter.language.register('facility', 'fsd') -- the someft filetype will use the python parser and queries.

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
