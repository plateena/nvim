return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
    { "<C-e>", function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end, desc = "Harpoon menu" },
    { "<a-1>", function() require("harpoon"):list():select(1) end },
    { "<a-2>", function() require("harpoon"):list():select(2) end },
    { "<a-3>", function() require("harpoon"):list():select(3) end },
    { "<a-4>", function() require("harpoon"):list():select(4) end },
    { "<a-5>", function() require("harpoon"):list():select(5) end },
    { "<a-h>", function() require("harpoon"):list():prev() end },
    { "<a-l>", function() require("harpoon"):list():next() end },
  },
  config = function()
    require("harpoon"):setup()
  end,
}
