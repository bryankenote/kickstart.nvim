return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            -- suggestion = {
            --     enable = true,
            --     auto_trigger = true,
            --     keymap = {
            --         accept = "<c-l>",
            --         next = "<c-j>",
            --         prev = "<c-k>",
            --         dismiss = "<c-h>",
            --     },
            -- },
            suggestion = { enabled = false },
            panel = { enabled = false },
        })
    end,
}
