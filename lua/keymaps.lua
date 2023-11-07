-- [[ Basic Keymaps ]]

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

vim.keymap.set('n', '<leader>Lc', '<cmd>e ~/.config/nvim<cr>', { desc = 'Edit [c]onfig' })

-- Diagnostic keymaps
vim.keymap.set('n', 'dk', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', 'dj', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

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

vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = '[W]rite file' })
vim.keymap.set('n', '<leader>q', '<cmd>confirm q<cr>', { desc = '[Q]uit' })

vim.keymap.set('n', '<leader>/', '<Plug>(comment_toggle_linewise_current)', { desc = 'Comment toggle line' })
vim.keymap.set('v', '<leader>/', '<Plug>(comment_toggle_linewise_visual)', { desc = 'Comment toggle lines' })

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- vim: ts=2 sts=2 sw=2 et
