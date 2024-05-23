return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "windwp/nvim-ts-autotag"
    },
    build = ":TSUpdate",
    config = function() 
        require("nvim-treesitter").setup({
            build = ":TSUpdate",
            config = function () 
                local configs = require("nvim-treesitter.configs")

                configs.setup({
                    ensure_installed = {
                        "bash",
                        "css",
                        "dockerfile",
                        "elixir",
                        "gitignore",
                        "html",
                        "javascript",
                        "json",
                        "lua",
                        "markdown",
                        "markdown_inline",
                        "query",
                        "tsx",
                        "typescript",
                        "vim",
                        "vimdoc",
                        "yaml",
                    },
                    sync_install = false,
                    highlight = { enable = true },
                    indent = { enable = true },  
                    autotag ={ enable = true },
                })
            end
        })
    end
}
