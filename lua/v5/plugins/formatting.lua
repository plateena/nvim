return {
    "stevearc/conform.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    ft = { "js", "ts", "php", "html", "css", "scss", "lua", "bash", "sh", "ts", "tsx", "jsx", "yaml", "json", "md" },
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters = {
                prettier = {
                    command = "npx",
                    args = {
                        "prettier",
                        "--stdin-filepath",
                        "$FILENAME",
                        "--plugin",
                        "/home/zack/.dotfiles/npm-global/lib/node_modules/@prettier/plugin-php/src/index.mjs",
                        "--config",
                        "/home/zack/.dotfiles/.prettierrc",
                        stdin = true,
                    },
                },
            },
            formatters_by_ft = {
                bash = { "beautysh", "beautysh" },
                css = { "prettier" },
                javascript = { "prettier" },
                json = { "prettier" },
                lua = { "stylua" },
                markdown = { "prettier" },
                php = { "prettier", "phpcbf" },
                ruby = { "prettier" },
                sh = { "beautysh" },
                typescript = { "prettier" },
                yaml = { "prettier" },
                zsh = { "beautysh" },
            },
            -- format_on_save = {
            --     lsp_fallback = true,
            --     async = false,
            --     timeout_ms = 1000,
            -- },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
                -- Get the start and end positions of the visual selection
                local start_pos = vim.fn.getpos("'<")
                local end_pos = vim.fn.getpos("'>")
                -- Convert positions to a range table
                local range = {
                    start = { start_pos[2], start_pos[3] },
                    ["end"] = { end_pos[2], end_pos[3] },
                }
                -- Format the selected range
                require("conform").format({ range = range })
            else
                -- Format the entire buffer in Normal mode
                require("conform").format()
            end
        end, { desc = "Format code" })
    end,
}
