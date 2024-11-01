return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = 'Silicon',
  config = function()
    require('silicon').setup {
      font = 'JetBrainsMono Nerd Font=34;Apple Color Emoji=34',
      theme = 'Visual Studio Dark+',
    }
  end,
}
