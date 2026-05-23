return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = { "echasnovski/mini.icons" },
  init = function()
    vim.opt.timeout = true
    vim.opt.timeoutlen = 500
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({ preset = "modern" })
    wk.add({
      { "<leader>a", group = "AI" },
      { "<leader>b", group = "Buffer" },
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>i", group = "Icon" },
      { "<leader>l", group = "LSP" },
      { "<leader>m", group = "Format" },
      { "<leader>o", group = "Options" },
      { "<leader>q", group = "Quit" },
      { "<leader>s", group = "Search/Replace" },
      { "<leader>u", group = "UI" },
      { "<leader>w", group = "Wiki/Write" },
      { "<leader>x", group = "Diagnostics" },
      { "<leader>oy", group = "Clipboard" },
      { "<leader>oyi", "<Cmd>setlocal paste<Cr>", desc = "Set paste true" },
      { "<leader>oyo", "<Cmd>setlocal nopaste<Cr>", desc = "Set paste false" },
      {
        "<leader>oh",
        function()
          vim.o.hlsearch = not vim.o.hlsearch
          print("hlsearch: " .. (vim.o.hlsearch and "on" or "off"))
        end,
        desc = "Toggle hlsearch",
      },
    })
    vim.api.nvim_set_hl(0, "WhichKey", { bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "none" })
    vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
  end,
}
