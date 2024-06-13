return {
    "vimwiki/vimwiki",
    init = function()
        vim.g.vimwiki_list = {
            {
                path = "~/Documents/notebooks/",
                syntax = "markdown",
                ext = ".md",
            }
        }

        vim.g.vimwiki_key_mappings = {
            all_maps = 0,
            global = 0,
        }
    end,
    config = function()
        vim.keymap.set('n', '<Cr>', '<Plug>VimwikiFollowLink')
    end
}
