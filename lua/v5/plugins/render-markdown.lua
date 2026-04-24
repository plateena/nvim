return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "vimwiki" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    latex = { enabled = false },
    -- render-markdown options
    file_types = { "markdown", "vimwiki" },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    -- register markdown parser for vimwiki
    vim.treesitter.language.register("markdown", "vimwiki")
  end,
}
