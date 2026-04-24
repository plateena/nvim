return {
  "lervag/wiki.vim",
  enabled = true,
  cmd = { "WikiIndex", "Wiki", "WikiOpen", "WikiTags" },
  ft = { "markdown" },

  init = function()
    vim.g.wiki_root = "~/Documents/wiki"
  end,

  config = function() end,
}
