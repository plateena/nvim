return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
        require("transparent").setup({
            groups = {
                -- default plus these two to preserve your cursor line highlights
                "Comment",
                "Conditional",
                "Constant",
                "CursorLine",
                "CursorLineNr",
                "EndOfBuffer",
                "Fidget",
                "Function",
                "Identifier",
                "LineNr",
                "Normal",
                "NormalNC",
                "Operator",
                "PreProc",
                "Repeat",
                "SignColumn",
                "Special",
                "Statement",
                "StatusLine",
                "StatusLineNC",
                "String",
                "Structure",
                "Todo",
                "Type",
                "Underlined",
                -- any others you need
            },
            extra_groups = {
                "BufferLine",
                "NvimTreeNormal",
                "NvimTreeWinSeparator",
                "NvimTreeBorder",
                "TelescopeNormal",
                "TelescopeBorder",
                "TelescopePromptNormal",
                "TelescopePromptBorder",
                "WhichKeyNormal",
                "WhichKeyBorder",
                "WhichKeyTitle",
                "LazyNormal",
            },
            -- optionally exclude specific groups if needed
            exclude_groups = {},
            on_clear = function()
                -- If you want, reapply some manual highlights
            end,

        })
    end,
}
