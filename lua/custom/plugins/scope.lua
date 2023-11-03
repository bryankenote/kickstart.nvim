return {
    "tiagovla/scope.nvim",
    config = function()
        require("scope").setup({
            restore_state = false, -- experimental
        })
        require("telescope").load_extension("scope")
    end
}
