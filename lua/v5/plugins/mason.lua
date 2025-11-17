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

        -- 🧩 Remove deprecated require("lspconfig")
        -- local lspconfig = require("lspconfig") ← REMOVE THIS LINE

        -- Function to check file size
        local function is_file_too_large(bufnr, max_lines)
            max_lines = max_lines or 1000
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            return line_count >= max_lines, line_count
        end

        local auto_enable_servers = {
            "bashls",
            "cssls",
            "docker_compose_language_service",
            "dockerls",
            "jsonls",
            "sqlls",
            "tailwindcss",
            "ts_ls",
        }

        mason.setup()

        mason_lspconfig.setup({
            automatic_enable = false,
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
                "ruby_lsp",
                "sqlls",
                "tailwindcss",
                "ts_ls",
                "yamlls",
            },
        })

        for _, server in ipairs(auto_enable_servers) do
            vim.lsp.config[server] = {
                on_attach = function(client, bufnr)
                    local too_large, line_count = is_file_too_large(bufnr)
                    if too_large then
                        client.stop()
                        vim.notify(
                            string.format("LSP '%s' disabled: file has %d lines (limit: %d)", server, line_count, 1000),
                            vim.log.levels.WARN
                        )
                    end
                end,
            }

            local ok, err = pcall(function()
                vim.lsp.enable(server)
            end)

            if not ok then
                vim.notify(string.format("Failed to enable LSP server '%s': %s", server, err), vim.log.levels.ERROR)
            end
        end

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier",
                "stylua",
                "phpcbf",
                "rubocop",
                "shfmt"
            },
        })
    end,
}
