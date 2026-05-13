return {
  -- Amazon Q inline completions
  {
    "awslabs/amazonq.nvim",
    opts = {
      ssoStartUrl = "https://inscale.awsapps.com/start",
    },
  },
  -- CodeCompanion for AI chat (uses Kiro CLI via ACP)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.icons",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>ai", "<cmd>CodeCompanionChat toggle<cr>", mode = { "n", "v" }, desc = "AI Chat toggle" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat add<cr>", mode = "v", desc = "AI Add to chat" },
    },
    opts = {
      adapters = {
        kiro = function()
          return require("codecompanion.adapters").extend("kiro", {})
        end,
      },
      strategies = {
        chat = { adapter = "kiro" },
        inline = { adapter = "kiro" },
      },
    },
  },
}
