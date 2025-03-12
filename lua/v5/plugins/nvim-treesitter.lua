return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        local parsers_config = require("nvim-treesitter.parsers").get_parser_configs()
        parsers_config.blade = {
            install_info = {
                url = "https://github.com/EmranMR/tree-sitter-blade",
                files = { "src/parser.c" },
                branch = "main",
            },
        }

        local ts = require("nvim-treesitter.configs")
        ts.setup({
            auto_install = true,
            ensure_installed = {
                -- 'help',
                'bash',
                'comment',
                'css',
                'diff',
                'dockerfile',
                'git_rebase',
                'gitcommit',
                'html',
                'javascript',
                'json',
                'lua',
                'lua',
                'markdown',
                'markdown_inline',
                'php',
                'ruby',
                'scss',
                'typescript',
                'vue',
            },
            sync_install = false,
            TSConfig = {},
            modules = {},
            ignore_install = {},
            indent = { enable = true },
            autotag = { enable = true },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            -- disabled on certain condition
            disable = function(_, buf)
                -- disabled when file too big
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        })

        vim.filetype.add({
            pattern = {
                [".*%.blade%.php"] = "blade",
            },
        })
    end,
}
