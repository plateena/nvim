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
  -- Suda (write with sudo)
  { "lambdalisue/suda.vim", event = { "BufReadPre", "BufNewFile" } },
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
  },
  -- Bullets for markdown lists
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    config = function()
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_outline_levels = { "num", "abc", "roman" }
      vim.g.bullets_nested_checkboxes = 1
      vim.g.bullets_checkbox_markers = " .oOx"
    end,
  },
}
