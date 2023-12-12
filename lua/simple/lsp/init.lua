local lspconfig = require('lspconfig')
require("mason").setup()
require("mason-lspconfig").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "lua_ls" },
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP Actions',
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local function setOpts(desc)
            return {
                desc = desc,
                buffer = ev.buf,
            }
        end

        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, setOpts("Lsp declaration"))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, setOpts("Lsp definition"))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, setOpts("Lsp Hover"))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, setOpts("Lsp implimentation"))
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, setOpts("Lsp signature help"))
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, setOpts("Lsp add workspace folder"))
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, setOpts("Lsp remove workspace folder"))
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, setOpts("Lsp list workspace folder"))
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, setOpts("Lsp type definition"))
        vim.keymap.set('n', '<space>lrn', vim.lsp.buf.rename, setOpts("Lsp rename"))
        vim.keymap.set('n', '<space>la', vim.lsp.buf.code_action, setOpts("Lsp code action"))
        vim.keymap.set('n', '<space>lre', vim.lsp.buf.references, setOpts("Lsp reference"))
        vim.keymap.set('n', '<space>lf', function()
            vim.lsp.buf.format { async = true }
        end, setOpts("Lsp format"))
    end,
})

require(VG.root_dir .. '.lsp.lua')
