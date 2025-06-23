return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      groups = {
        -- default plus these two to preserve your cursor line highlights
        "Normal",
        "NormalNC",
        "Comment",
        "Constant",
        "Special",
        "Identifier",
        "Statement",
        "PreProc",
        "Type",
        "Underlined",
        "Todo",
        "String",
        "Function",
        "Conditional",
        "Repeat",
        "Operator",
        "Structure",
        "LineNr",
        -- "CursorLine",
        "CursorLineNr",
        "SignColumn",
        "StatusLine",
        "StatusLineNC",
        "EndOfBuffer",
        -- any others you need
      },
      extra_groups = {
        "BufferLine",
        "NvimTree",
        "Telescope",
        "Harpoon",
        "Fidget",
      },
      -- optionally exclude specific groups if needed
      exclude_groups = {},
    })
  end,
}
