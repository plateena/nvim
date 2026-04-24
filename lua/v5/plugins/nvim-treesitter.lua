return {
  "nvim-treesitter/nvim-treesitter",
  -- event = { "BufReadPre", "BufNewFile" },
  lazy = false,
  build = ":TSUpdate",
  config = function()
    -- Register custom blade parser
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

    -- Blade filetype detection
    vim.filetype.add({
      extension = {
        blade = "blade",
      },
      pattern = {
        [".*%.blade%.php"] = "blade",
      },
    })

    -- Use the new config module name
    local ts_config = require("nvim-treesitter.config")

    ts_config.setup({
      ensure_installed = {
        "bash",
        "c",
        "lua",
        "markdown",
        "markdown_inline",
        "regex",
        "vim",
        "vimdoc",
        "blade",
      },
      highlight = {
        enable = true,
        -- additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      fold = {
        enable = true,
        method = "expr",
        expr = "v:lua.vim.treesitter.foldexpr()",
      },
    })
  end,
}
