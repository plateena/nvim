return {
  "mason-org/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      automatic_enable = false,
      ensure_installed = {
        "bashls", "cssls", "docker_compose_language_service", "dockerls",
        "emmet_ls", "jsonls", "lua_ls", "phpactor", "ruby_lsp",
        "sqlls", "tailwindcss", "ts_ls", "yamlls",
      },
    })
    require("mason-tool-installer").setup({
      ensure_installed = {
        "prettier", "prettierd", "stylua", "phpcbf", "rubocop", "shfmt",
        "eslint_d", "shellcheck", "ruff", "phpstan",
      },
    })
  end,
}
