require("mason").setup()
require("mason-lspconfig").setup({
    automatic_installation = true
})
local lspconfig = require('lspconfig')

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>ef', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>eq', vim.diagnostic.setloclist)

lspconfig.lua_ls.setup({
    diagnostics = {
        globals = { "vim" }
    },
    workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
    }
})
