return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        -- Blade parser configuration
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
        parser_config.blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = { "src/parser.c" },
                branch = "main",
                generate_requires_npm = true,
                requires_generate_from_grammar = true,
            },
            filetype = "blade",
        }

        -- Blade filetype detection
        vim.filetype.add({
            extension = {
                blade = "blade",
            },
            pattern = {
                [".*%.blade%.php"] = "blade",
            },
        })

        -- Treesitter setup
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash",
                "c",
                "comment",
                "css",
                "diff",
                "dockerfile",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "html",
                "javascript",
                "json",
                "jsonc",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "php",
                "python",
                "regex",
                "ruby",
                "scss",
                "sql",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "vue",
                "yaml",
            },
            sync_install = false,
            auto_install = true,
            ignore_install = { "help" },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown" },
                disable = function(_, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end

                    local max_lines = 5000
                    if vim.api.nvim_buf_line_count(buf) > max_lines then
                        return true
                    end
                end,
            },

            indent = {
                enable = true,
                disable = { "python", "yaml" },
            },

            autotag = {
                enable = true,
                filetypes = {
                    "html",
                    "javascript",
                    "typescript",
                    "javascriptreact",
                    "typescriptreact",
                    "svelte",
                    "vue",
                    "tsx",
                    "jsx",
                    "php",
                    "blade",
                    "markdown",
                    "xml",
                },
            },
        })
    end,
}
