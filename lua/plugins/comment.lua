return {
    {
        "folke/ts-comments.nvim",
        version = "v1.5.0",
        opts = {},
        event = "VeryLazy",
        enabled = vim.fn.has("nvim-0.10.0") == 1,
    },
    {
        "numToStr/Comment.nvim",
        tag = "v0.8.0",
        opts = {
            mappings = {
                ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                basic = true,
                ---Extra mapping; `gco`, `gcO`, `gcA`
                extra = false,
            },
            toggler = {
                ---Line-comment toggle keymap
                line = "<leader>/",
                ---Block-comment toggle keymap
                block = "gbc",
            },
            opleader = {
                line = "<leader>/",
                block = "gb",
            },
        },
    },
}
