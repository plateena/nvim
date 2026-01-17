return {
    {
        "vimwiki/vimwiki",
        enabled = false,
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
                pattern = { "vimwiki" },
                callback = function(args)
                    -- Follow link
                    vim.keymap.set("n", "<CR>", "<Plug>VimwikiFollowLink", {
                        buffer = args.buf,
                        desc = "Vimwiki: follow link",
                        noremap = true,
                        silent = true,
                    })

                    -- Next link with count support
                    vim.keymap.set("n", "<Tab>", function()
                        local count = vim.v.count1
                        for _ = 1, count do
                            vim.cmd("VimwikiNextLink")
                        end
                    end, { buffer = args.buf, desc = "Vimwiki: next link (with count)" })

                    -- Previous link with count support
                    vim.keymap.set("n", "<S-Tab>", function()
                        local count = vim.v.count1
                        for _ = 1, count do
                            vim.cmd("VimwikiPrevLink")
                        end
                    end, { buffer = args.buf, desc = "Vimwiki: previous link (with count)" })
                end,
            })
        end,

        dependencies = {
            {
                "MeanderingProgrammer/render-markdown.nvim",
                ft = { "markdown", "vimwiki" },
                dependencies = {
                    "nvim-treesitter/nvim-treesitter",
                    "echasnovski/mini.nvim", -- or mini.icons / nvim-web-devicons
                },
                opts = {
                    file_types = { "vimwiki" },
                },
                config = function(_, opts)
                    require("render-markdown").setup(opts)
                    vim.treesitter.language.register("markdown", "vimwiki")
                end,
            },
        },
    },
}
