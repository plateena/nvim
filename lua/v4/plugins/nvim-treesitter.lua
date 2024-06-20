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
            highlight = { enabled = true },
            indent = { enable = true },
            autotag = { enable = true },

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
