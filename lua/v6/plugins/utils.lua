return {
  -- Surround (replaces vim-sandwich)
  {
    "kylechui/nvim-surround",
    version = "^3",
    event = "VeryLazy",
    opts = {},
  },
  -- Comments (enhances native gc for embedded languages)
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
  -- Emmet
  {
    "olrtg/nvim-emmet",
    keys = {
      { "<C-y>,", function() require("nvim-emmet").wrap_with_abbreviation() end, mode = { "n", "v", "i" } },
    },
  },
  -- Icon picker
  {
    "ziontee113/icon-picker.nvim",
    keys = {
      { "<Leader>ii", function()
          vim.ui.select({ "emoji", "nerd_font", "alt_font", "html_colors", "symbols" },
            { prompt = "Icon Type" }, function(choice)
              if choice then vim.cmd("IconPickerNormal " .. choice) end
            end)
        end, desc = "Pick icon" },
      { "<Leader>iy", "<cmd>IconPickerYank<CR>", desc = "Yank icon" },
    },
    opts = { disable_legacy_commands = true },
  },
  -- Wiki
  {
    "lervag/wiki.vim",
    cmd = { "WikiIndex", "Wiki", "WikiOpen", "WikiTags" },
    ft = { "markdown" },
    keys = {
      { "<leader>ww", "<cmd>WikiIndex<cr>", desc = "Wiki index" },
      { "<leader>wn", "<cmd>WikiOpen<cr>", desc = "Wiki open" },
      { "<leader>wt", "<cmd>WikiTags<cr>", desc = "Wiki tags" },
    },
  },
}
