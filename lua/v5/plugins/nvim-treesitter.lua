return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
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

    -- Enable highlighting with core TreeSitter (Neovim 0.11+)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function(ctx)
        pcall(vim.treesitter.start, ctx.buf)
      end,
    })

    -- Optionally enable folding via TreeSitter
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
      end,
    })
  end,
}
