return {
  "bullets-vim/bullets.vim",
  ft = { "markdown", "text", "gitcommit" },
  config = function()
    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
      "gitcommit",
    }

    vim.g.bullets_outline_levels = { "num", "abc", "roman" }

    vim.g.bullets_nested_checkboxes = 1
    vim.g.bullets_checkbox_markers = " .oOx"

    vim.g.bullets_auto_indent = 1
    vim.g.bullets_set_mappings = 1
  end,
}
