return {
  "awslabs/amazonq.nvim",
  event = "InsertEnter",
  opts = {
    ssoStartUrl = vim.g.ai_sso_url or "https://inscale.awsapps.com/start",
    inline_suggest = true,
  },
  config = function(_, opts)
    require("amazonq").setup(opts)
    -- Fix: clear the broken CmdUndefined handler that spams "removed" for ANY undefined command
    for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = "amazonq.lsp", event = "CmdUndefined" })) do
      vim.api.nvim_del_autocmd(autocmd.id)
    end
  end,
}
