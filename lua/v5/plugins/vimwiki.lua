return {
    "vimwiki/vimwiki",
    ft = { "markdown", "md" },
    cmd = "VimwikiIndex",
    init = function()
        vim.g.vimwiki_list = {
            {
                path = "~/Documents/notebooks/",
                syntax = "markdown",
                ext = ".md",
            },
        }

        vim.g.vimwiki_key_mappings = {
            all_maps = 0,
            global = 0,
        }
    end,
    keys = {
        {"<Cr>","<Plug>VimwikiFollowLink", mode = "n", desc = "Vimwiki follow link" },
    }
}
