return {
  "folke/flash.nvim",
  event = "VeryLazy",
  keys = {
    {
      "s",
      function()
        require("flash").jump()
      end,
      mode = { "n", "x", "o" },
      desc = "Flash jump",
    },
    {
      "S",
      function()
        require("flash").treesitter()
      end,
      mode = { "n", "x", "o" },
      desc = "Flash treesitter",
    },
    {
      "r",
      function()
        require("flash").remote()
      end,
      mode = "o",
      desc = "Remote flash",
    },
    {
      "<c-s>",
      function()
        require("flash").toggle()
      end,
      mode = "c",
      desc = "Toggle flash search",
    },
  },
  opts = {
    modes = {
      char = { enabled = true, jump_labels = true },
      search = { enabled = true },
    },
  },
}
