return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<space>lp",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = { "n", "v" },
            desc = "Format buffer",
        },
        {
            "<space>lt",
            function()
                vim.g.conform_format_on_save = not vim.g.conform_format_on_save
                print("Format on save: " .. (vim.g.conform_format_on_save and "enabled" or "disabled"))
            end,
            desc = "Toggle format on save",
        },
    },
    init = function()
        -- Set default state
    end,
    opts = {
        formatters_by_ft = {
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            vue = { "prettier" },
            css = { "prettier" },
            scss = { "prettier" },
            less = { "prettier" },
            html = { "prettier" },
            json = { "prettier" },
            jsonc = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            graphql = { "prettier" },
            handlebars = { "prettier" },
            php = { "php_cs_fixer" },
            ruby = { "rubocop" },
            lua = { "stylua" },
            python = { "black", "isort" },
        },
        format_on_save = function(bufnr)
            if vim.g.format_on_save_enabled then
                return {
                    timeout_ms = 500,
                    lsp_fallback = true,
                }
            end
        end,
    },
}
