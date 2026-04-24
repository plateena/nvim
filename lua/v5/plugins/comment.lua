return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = { enable_autocmd = false },
    },
  },
  -- keys = {
  --   { "gcc", mode = { "n", "v" } },
  --   { "gbc", mode = { "n", "v" } },
  -- },
  config = function()
    comment.setup({})
  end,
}
