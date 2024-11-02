return {
  'olimorris/persisted.nvim',
  lazy = false,
  config = function()
    require('persisted').setup {
      autostart = true,
      -- autosave = true,
      autoload = true,
      use_git_branch = true,
      default_branch = 'master',
      telescope = {
        reset_prompt = true, -- Reset the Telescope prompt after an action?
        mappings = { -- table of mappings for the Telescope extension
          change_branch = '<c-b>',
          copy_session = '<c-c>',
          delete_session = 'dd',
        },
      },
    }
  end,
}
