return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "vimwiki" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  opts = {
    file_types = { "markdown", "vimwiki" },
    latex = { enabled = false },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    vim.treesitter.language.register("markdown", "vimwiki")
  end,
}
