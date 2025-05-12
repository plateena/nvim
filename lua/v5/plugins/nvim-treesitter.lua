return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        -- Custom parser for Blade templates
        require("nvim-treesitter.parsers").get_parser_configs().blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = { "src/parser.c" },
                branch = "main",
                generate_requires_npm = true, -- Needed for some parsers
                requires_generate_from_grammar = true,
            },
            filetype = "blade", -- Associate with blade filetype
        }

        -- Register blade filetype
        vim.filetype.add({
            extension = {
                blade = "blade",
            },
            pattern = {
                [".*%.blade%.php"] = "blade",
            },
        })

        require("nvim-treesitter.configs").setup({
            -- Installation configuration
            auto_install = true,
            sync_install = false,
            ignore_install = { "help" }, -- Don't install help parser

            -- List of parsers to install
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

            -- Highlighting configuration
            highlight = {
                enable = true,
                disable = function(_, buf)
                    -- Disable for large files
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end

                    -- Disable for files with too many lines
                    local max_lines = 5000
                    if vim.api.nvim_buf_line_count(buf) > max_lines then
                        return true
                    end
                end,
                additional_vim_regex_highlighting = { "markdown" }, -- Needed for some markdown features
            },

            -- Indentation
            indent = {
                enable = true,
                disable = { "python", "yaml" }, -- Some languages have better native indentation
            },

            -- Autotag configuration (requires nvim-ts-autotag)
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
