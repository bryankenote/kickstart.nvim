return {
    "petertriho/nvim-scrollbar",
    config = function()
        require("scrollbar.handlers.gitsigns").setup()

        require("scrollbar").setup({
            handlers = {
                cursor = false,
            },
            handle = {
                color = "#595959",
            },
        })
    end,
}
