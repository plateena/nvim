-- Import necessary modules
local lspconfig = require('lspconfig')
local cmp_lsp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Diagnostics Handling
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,         -- Enable underline for diagnostics
        virtual_text = false,     -- Disable virtual text
        signs = true,             -- Show signs in the gutter
        update_in_insert = false, -- Delay updating diagnostics while in insert mode
        float = { border = "single" }, -- Floating window border style
    }
)

-- Hover and Signature Help Windows
local border_style = "single"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = border_style
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = border_style
    }
)

-- Diagnostics Float Window Configuration
vim.diagnostic.config {
    float = { border = border_style }
}

-- Custom Diagnostic Signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Global Mappings
vim.api.nvim_set_keymap('n', '<leader>lo', vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Diagnostic open float" })
vim.api.nvim_set_keymap('n', '<leader>d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Diagnostic previous issue" })
vim.api.nvim_set_keymap('n', '<leader>D', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Diagnostic next issue" })
vim.api.nvim_set_keymap('n', '<leader>lq', vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Diagnostic quickfix" })

-- LSP Attach Autocommand
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer-local mappings
        local function setOpts(desc)
            return {
                desc = desc,
                buffer = ev.buf,
            }
        end

        -- Buffer-local Mappings
        vim.api.nvim_set_keymap('n', 'gD', vim.lsp.buf.declaration, setOpts("Lsp declaration"))
        vim.api.nvim_set_keymap('n', 'gd', vim.lsp.buf.definition, setOpts("Lsp definition"))
        vim.api.nvim_set_keymap('n', 'K', vim.lsp.buf.hover, setOpts("Lsp Hover"))
        vim.api.nvim_set_keymap('n', 'gi', vim.lsp.buf.implementation, setOpts("Lsp implementation"))
        vim.api.nvim_set_keymap('n', '<C-k>', vim.lsp.buf.signature_help, setOpts("Lsp signature help"))
        vim.api.nvim_set_keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, setOpts("Lsp add workspace folder"))
        vim.api.nvim_set_keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, setOpts("Lsp remove workspace folder"))
        vim.api.nvim_set_keymap('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, setOpts("Lsp list workspace folder"))
        vim.api.nvim_set_keymap('n', '<leader>D', vim.lsp.buf.type_definition, setOpts("Lsp type definition"))
        vim.api.nvim_set_keymap('n', '<leader>lrn', vim.lsp.buf.rename, setOpts("Lsp rename"))
        vim.api.nvim_set_keymap('n', '<leader>la', vim.lsp.buf.code_action, setOpts("Lsp code action"))
        vim.api.nvim_set_keymap('n', '<leader>lre', vim.lsp.buf.references, setOpts("Lsp reference"))
        vim.api.nvim_set_keymap('n', '<leader>lf', function()
            vim.lsp.buf.format { async = true }
        end, setOpts("Lsp format"))
    end,
})

-- Additional Language Server Configuration (e.g., lua language server)
lspconfig.lua_ls.setup({
    capabilities = cmp_lsp_capabilities,
})
