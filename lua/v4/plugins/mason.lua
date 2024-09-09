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

        mason.setup()
        mason_lspconfig.setup({
            ensure_installed = {
                "bashls",
                "cssls",
                "docker_compose_language_service",
                "dockerls",
                "emmet_language_server",
                "emmet_ls",
                "jsonls",
                "lua_ls",
                "phpactor",
                "sqlls",
                "tailwindcss",
                "ts_ls",
                "yamlls",
            },
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier",
                "stylua",
                "phpcbf",
            }
        })
    end
}
