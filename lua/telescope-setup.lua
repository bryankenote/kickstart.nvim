-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local function custom_path_display(opts, path)
  local cwd = vim.loop.cwd()

  if cwd == nil or not cwd:match 'AcademicServices' then
    return path
  end

  local segments = vim.split(path, '/')

  if #segments < 2 then
    return path
  end

  local segment = segments[2]

  local display_name = ''
  if segment ~= nil then
    if string.find(segment, 'Faithlife.AcademicDesk.Client') then
      display_name = '[Desk.C]'
    elseif string.find(segment, 'Faithlife.AcademicDesk.Server') then
      display_name = '[Desk.S]'
    elseif string.find(segment, 'Faithlife.AcademicPortal.Client') then
      display_name = '[Portal.C]'
    elseif string.find(segment, 'Faithlife.AcademicPortal.Server') then
      display_name = '[Portal.S]'
    elseif string.find(segment, 'Faithlife.AcademicServices.AcademicApi.v1.WebApi') then
      display_name = '[WebApi]'
    elseif string.find(segment, 'Faithlife.AcademicServices.Subscriber') then
      display_name = '[Subscriber]'
    elseif string.find(segment, 'Faithlife.AcademicServices.Services') then
      display_name = '[Services]'
    elseif string.find(segment, 'Faithlife.AcademicServices.Scheduler') then
      display_name = '[Scheduler]'
    elseif string.find(segment, 'Faithlife.AcademicServices.JobConsole') then
      display_name = '[JobConsole]'
    elseif string.find(segment, 'Faithlife.AcademicServices.Data.Entities') then
      display_name = '[Entities]'
    elseif string.find(segment, 'Faithlife.AcademicServices.Data') then
      display_name = '[Data]'
    elseif string.find(segment, 'Faithlife.AcademicServices.IntegrationTests') then
      display_name = '[IntegrationTests]'
    elseif string.find(segment, 'Faithlife.AcademicServices.AcademicApi.Tests') then
      display_name = '[AcademicApi.Tests]'
    elseif string.find(segment, 'Faithlife.AcademicServices.LtiProvider.v1.Web.Tests') then
      display_name = '[LtiProvider.Tests]'
    end
  end
  if display_name == '' or segment == nil then
    return path
  end

  -- Get the remaining path after the segment
  local index = string.find(path, segment) + #segment + 1
  local sub_path = string.sub(path, index)

  -- Get path past "/src" if possible
  sub_path = vim.fn.substitute(sub_path, '^src', '', '')

  -- Return the formatted path
  return display_name .. ' ' .. sub_path
end

local _actions = require 'telescope.actions'
-- local _persisted_actions = require 'telescope._extensions.persisted.actions'
require('telescope').setup {
  defaults = {
    show_dotfiles = true,
    custom_path_display = custom_path_display,
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
    diagnostics = {
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

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[S]earch in current [B]uffer' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').live_grep, { desc = '[S]earch [T]ext' })
vim.keymap.set('n', '<leader><tab>', '<cmd>Telescope telescope-tabs list_tabs initial_mode=insert<cr>', { desc = 'Search tabs' })
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

-- vim: ts=2 sts=2 sw=2 et
