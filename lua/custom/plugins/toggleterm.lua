return {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
        require('toggleterm').setup {
            open_mapping = '<F2>',
            direction = 'float',
            size = 40,
            start_in_insert = true
        }
    end
}
