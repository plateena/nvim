return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "vimwiki" },
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  config = function()
    require("render-markdown").setup({
      file_types = { "markdown", "vimwiki" },
      latex = { enabled = false },
    })
    vim.treesitter.language.register("markdown", "vimwiki")
  end,
}
