return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    vim.treesitter.language.add("blade", {
      install_info = {
        url = "https://github.com/EmranMR/tree-sitter-blade",
        files = { "src/parser.c" },
        branch = "main",
        generate_requires_npm = true,
        requires_generate_from_grammar = true,
      },
      filetype = "blade",
    })

    vim.filetype.add({
      extension = { blade = "blade" },
      pattern = { [".*%.blade%.php"] = "blade" },
    })

    require("nvim-treesitter.config").setup({
      ensure_installed = {
        "bash", "c", "css", "html", "javascript", "json", "lua",
        "markdown", "markdown_inline", "php", "python", "regex",
        "ruby", "tsx", "typescript", "vim", "vimdoc", "yaml", "blade",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
