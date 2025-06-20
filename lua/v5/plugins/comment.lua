return {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            opts = { enable_autocmd = false },
        },
    },
    config = function()
        local comment = require("Comment")
        local ts_context = require("ts_context_commentstring.integrations.comment_nvim")

        comment.setup({
            padding = true, -- add space between comment and code
            sticky = true,  -- keep cursor in place
            ignore = "^$",  -- ignore empty lines
            toggler = {
                line = "gcc",
                block = "gbc",
            },
            opleader = {
                line = "gc",
                block = "gb",
            },
            extra = {
                above = "gcO",
                below = "gco",
                eol   = "gcA",
            },
            mappings = {
                basic = true,
                extra = true,
            },
            pre_hook = nil,
            post_hook = nil,
        })
    end,
}
