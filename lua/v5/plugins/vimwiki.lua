return {
    {
        "vimwiki/vimwiki",
        ft = { "markdown", "vimwiki" },
        cmd = "VimwikiIndex",
        init = function()
            vim.g.vimwiki_global_ext = 0
            vim.g.vimwiki_list = {
                {
                    path = "~/Documents/notebooks/",
                    syntax = "markdown",
                    ext = ".md",
                },
            }
            vim.g.vimwiki_key_mappings = { all_maps = 0, global = 0 }
        end,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "vimwiki" },
                callback = function(args)
                    vim.keymap.set(
                        "n",
                        "<CR>",
                        "<Plug>VimwikiFollowLink",
                        { buffer = args.buf, desc = "Vimwiki: follow link", noremap = true }
                    )
                end,
            })
        end,

        -- Move render-markdown into dependencies
        dependencies = {
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft = { "markdown", "vimwiki" },
                dependencies = {
                    "nvim-treesitter/nvim-treesitter",
                    "echasnovski/mini.nvim", -- or mini.icons / nvim-web-devicons
                },
                opts = {
                    file_types = { "markdown", "vimwiki" },
                },
                config = function(_, opts)
                    require("render-markdown").setup(opts)
                    vim.treesitter.language.register("markdown", "vimwiki")
                end,
            },
        },
    },
}
