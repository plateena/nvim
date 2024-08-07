return {
    "stevearc/conform.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    ft = { "js", "ts", "php", "html", "css", "scss", "lua", "bash", "sh", "ts", "tsx", "jsx", "yaml", "json", "md" },
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                css = { "prettier" },
                javascript = { "prettier" },
                json = { "prettier" },
                lua = { "stylua" },
                markdown = { "prettier" },
                php = { "prettier", "prettier-php", "phpcbf" },
                typescript = { "prettier" },
                yaml = { "prettier" },
                bash = { "bashls", "beautysh" },
                sh = { "bashls", "beautysh" },
                zsh = { "bashls", "beautysh" },
            },
            -- format_on_save = {
            --     lsp_fallback = true,
            --     async = false,
            --     timeout_ms = 1000,
            -- },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({})
        end, { desc = "Format file on range (in visual mode)" })
    end,
}
