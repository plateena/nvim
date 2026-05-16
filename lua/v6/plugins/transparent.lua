return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      groups = {
        "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
        "Statement", "PreProc", "Type", "Underlined", "Todo", "String",
        "Function", "Conditional", "Repeat", "Operator", "Structure",
        "LineNr", "CursorLine", "CursorLineNr", "EndOfBuffer", "SignColumn",
      },
      extra_groups = {
        "NormalFloat", "FloatBorder", "WhichKeyNormal", "WhichKeyBorder",
        "WhichKeyTitle", "LazyNormal", "SnacksNormal", "SnacksBorder",
      },
    })
  end,
}
