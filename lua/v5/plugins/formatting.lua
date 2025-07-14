return {
    "stevearc/conform.nvim",
    ft = {
        "javascript", "typescript", "php", "html", "css", "scss", "lua", "bash",
        "sh", "tsx", "jsx", "yaml", "json", "markdown", "ruby"
    },
    keys = {
        {
            "<leader>mp",
            function()
                if vim.fn.mode():match("[vV]") then
                    local s_pos = vim.fn.getpos("'<")
                    local e_pos = vim.fn.getpos("'>")
                    require("conform").format({
                        range = {
                            start = { s_pos[2], s_pos[3] - 1 },   -- Convert to 0-indexed
                            ["end"] = { e_pos[2], e_pos[3] - 1 }, -- Convert to 0-indexed
                        },
                    })
                else
                    require("conform").format()
                end
            end,
            mode = { "n", "v" },
            desc = "Format code or selected range",
        },
    },
    config = function()
        local conform = require("conform")
        local php_plugin = "/home/zack/.dotfiles/npm-global/lib/node_modules/@prettier/plugin-php/src/index.mjs"
        local fallback_config = vim.fn.expand("~/.dotfiles/.prettierrc")

        -- Check if a Prettier config exists in the current working directory
        local function has_local_prettier_config()
            local config_files = {
                ".prettierrc",
                ".prettierrc.json",
                ".prettierrc.js",
                ".prettierrc.yaml",
                ".prettierrc.yml",
                "prettier.config.js",
            }

            for _, file in ipairs(config_files) do
                local path = vim.loop.cwd() .. "/" .. file
                local stat = vim.loop.fs_stat(path)
                if stat then return true end
            end

            return false
        end

        conform.setup({
            formatters = {
                prettier_with_php = {
                    command = "prettier",
                    args = function(ctx)
                        local args = {
                            "--stdin-filepath", "$FILENAME",
                            "--plugin", php_plugin,
                        }

                        if not has_local_prettier_config() then
                            table.insert(args, "--config")
                            table.insert(args, fallback_config)
                        end

                        return args
                    end,
                stdin = true,
                },
                prettier_standard = {
                    command = "prettier",
                    args = {
                        "--stdin-filepath", "$FILENAME",
                        "--config", prettier_config
                    },
                    stdin = true,
                },
                rubocop_fix = {
                    command = "rubocop",
                    args = {
                        "--stdin", "$FILENAME",
                        "--auto-correct",
                        "--format", "quiet"
                    },
                    stdin = true,
                },
            },
            formatters_by_ft = {
                bash = { "beautysh" },
                sh = { "beautysh" },
                zsh = { "beautysh" },
                css = { "prettier_standard" },
                scss = { "prettier_standard" },
                html = { "prettier_standard" },
                javascript = { "prettier_standard" },
                typescript = { "prettier_standard" },
                tsx = { "prettier_standard" },
                jsx = { "prettier_standard" },
                json = { "prettier_standard" },
                yaml = { "prettier_standard" },
                markdown = { "prettier_standard" },
                lua = { "stylua" },
                php = { "prettier_with_php", "phpcbf" },
                ruby = { "rubocop_fix" }, -- Using custom rubocop formatter
            },
            format_on_save = function(bufnr)
                if vim.g.format_on_save_enabled then
                    return {
                        timeout_ms = 3000, -- Increased timeout
                        lsp_fallback = true,
                    }
                end
            end,
        })
    end,
}
