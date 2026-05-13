-- mason.nvim setup
return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    local function is_file_too_large(bufnr, max_lines)
      max_lines = max_lines or 1000
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      return line_count >= max_lines, line_count
    end

    mason.setup()

    mason_lspconfig.setup({
      automatic_enable = false,
      ensure_installed = {
        "bashls",
        "cssls",
        "docker_compose_language_service",
        "dockerls",
        "emmet_ls",
        "jsonls",
        "lua_ls",
        "phpactor",
        "ruby_lsp",
        "sqlls",
        "tailwindcss",
        "ts_ls",
        "yamlls",
      },
    })

    -- Don't auto-enable servers - let native LSP handle it

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "phpcbf",
        "rubocop",
        "shfmt",
      },
    })
  end,
}
