return {
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      local icons = require("mini.icons")
      icons.setup({
        file = {
          ["blade.php"] = { glyph = "󰫐", hl = "MiniIconsRed" },
        },
      })
      icons.mock_nvim_web_devicons()
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
}
