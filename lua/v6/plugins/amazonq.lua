return {
  "awslabs/amazonq.nvim",
  event = "InsertEnter",
  opts = {
    ssoStartUrl = vim.g.ai_sso_url or "https://inscale.awsapps.com/start",
    inline_suggest = true,
  },
}
