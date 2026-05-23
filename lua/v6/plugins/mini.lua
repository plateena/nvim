return {
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      local icons = require("mini.icons")
      icons.setup({
        file = {
          ["blade.php"] = { glyph = "", hl = "MiniIconsRed" },
        },
        extension = {
          php = { glyph = "", hl = "MiniIconsPurple" },
          yaml = { glyph = "", hl = "MiniIconsYellow" },
          yml = { glyph = "", hl = "MiniIconsYellow" },
        },
      })
      icons.mock_nvim_web_devicons()
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({})
    end,
  },
  {
    "echasnovski/mini.align",
    keys = {
      { "ga", mode = { "n", "x" }, desc = "Align" },
      { "gA", mode = { "n", "x" }, desc = "Align with preview" },
    },
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup({})
    end,
  },
}
