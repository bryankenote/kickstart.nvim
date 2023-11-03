return {
    "dharmx/track.nvim",
    config = function()
        require("track").setup({
            pickers = {
                views = {
                    path_display = {
                        absolute = false,
                        shorten = 100,
                    },
                    prompt_prefix = "> ",
                    wrap_results = true,
                    layout_strategy = "horizontal",
                    layout_config = {
                        prompt_position = "top",
                        width = 0.95,
                        height = 0.90,
                        preview_width = 0.5,
                    },
                },
            }
        })
    end
}
