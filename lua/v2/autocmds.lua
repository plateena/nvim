-- Define autocmds (Auto Commands)
vim.api.nvim_exec([[
  augroup mygroup
    autocmd!
  augroup END
]], false)
    -- autocmd BufWritePre * :lua vim.lsp.buf.formatting_sync()
