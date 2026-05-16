return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    { "<leader>st", "<cmd>TodoQuickFix<cr>", desc = "TODO quickfix" },
  },
  config = function()
    require("todo-comments").setup({
      signs = true,
      keywords = {
        TODO = { icon = "", color = "info" },
        FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "DEBUG" } },
        HACK = { icon = "", color = "warning" },
        WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = "", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        REFACTOR = { icon = "", color = "hint", alt = { "CLEANUP", "IMPROVE" } },
      },
    })
  end,
}
