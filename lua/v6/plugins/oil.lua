return {
  "stevearc/oil.nvim",
  dependencies = { "echasnovski/mini.icons" },
  cmd = "Oil",
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Oil file manager" },
    { "<leader>eo", "<cmd>Oil<cr>", desc = "Oil file manager" },
    { "<leader>eO", function() require("oil").open(vim.fn.getcwd()) end, desc = "Oil root dir" },
  },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      view_options = { show_hidden = true },
      keymaps = {
        ["q"] = "actions.close",
        ["<C-s>"] = false,
      },
    })
  end,
}
