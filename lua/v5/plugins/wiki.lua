return {
    "lervag/wiki.vim",
    enabled = true,
    cmd = { "WikiIndex", "Wiki", "WikiOpen" },
    ft = { "markdown" },
    init = function()
        -- wiki root folder
        vim.g.wiki_root = "~/Documents/wiki"
    end,
    config = function() end,
}
