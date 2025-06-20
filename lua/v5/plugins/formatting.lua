return {
    "stevearc/conform.nvim",
    ft = {
        "js", "ts", "php", "html", "css", "scss", "lua", "bash",
        "sh", "tsx", "jsx", "yaml", "json", "md"
    },
    config = function()
        local conform = require("conform")

        local php_plugin = "/home/zack/.dotfiles/npm-global/lib/node_modules/@prettier/plugin-php/src/index.mjs"
        local ruby_plugin = "/home/zack/.dotfiles/npm-global/lib/node_modules/@prettier/plugin-ruby/src/plugin.js"
        local prettier_config = "/home/zack/.dotfiles/.prettierrc"

        conform.setup({
            formatters = {
                prettier = {
                    command = "npx",
                    args = {
                        "prettier",
                        "--stdin-filepath", "$FILENAME",
                        "--plugin", php_plugin,
                        "--plugin", ruby_plugin,
                        "--config", prettier_config
                    },
                    stdin = true,
                },
            },
            formatters_by_ft = {
                bash = { "beautysh" },
                sh = { "beautysh" },
                zsh = { "beautysh" },
                css = { "prettier" },
                scss = { "prettier" },
                html = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                tsx = { "prettier" },
                jsx = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
                php = { "prettier", "phpcbf" },
                ruby = { "prettier" },
            },
            format_on_save = function(bufnr)
                if vim.g.format_on_save_enabled then
                    return {
                        timeout_ms = 500,
                        lsp_fallback = true,
                    }
                end
            end,
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
                local start_pos = vim.fn.getpos("'<")
                local end_pos = vim.fn.getpos("'>")
                local range = {
                    start = { start_pos[2], start_pos[3] },
                    ["end"] = { end_pos[2], end_pos[3] },
                }
                conform.format({ range = range })
            else
                conform.format()
            end
        end, { desc = "Format code" })
    end,
}
