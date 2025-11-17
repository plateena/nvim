return {
    "lervag/wiki.vim",
    -- enabled = false,
    ft = { "markdown" },
    init = function()
        -- wiki root folder
        vim.g.wiki_root = "~/Documents/wiki"
    end,
    config = function() end,
}
