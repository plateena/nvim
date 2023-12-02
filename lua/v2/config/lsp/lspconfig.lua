-- Import necessary modules
local lspconfig = require('lspconfig')
local cmp_lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

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
        border = border_style  -- Use the specified border style
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = border_style  -- Use the specified border style
    }
)

-- Diagnostics Float Window Configuration
vim.diagnostic.config {
    float = { border = border_style }  -- Use the specified border style
}

-- Custom Diagnostic Signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Global Mappings
vim.keymap.set('n', '<leader>lo', vim.diagnostic.open_float, { desc = "Diagnostic open float" })
vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_prev, { desc = "Diagnostic previous issue" })
vim.keymap.set('n', '<leader>D', vim.diagnostic.goto_next, { desc = "Diagnostic next issue" })
vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

-- LSP Attach Autocommand
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Buffer-local mappings
        local function set_opts(desc)
            return {
                desc = desc,
                buffer = ev.buf,
            }
        end

        -- Buffer-local Mappings
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, set_opts("Lsp declaration"))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, set_opts("Lsp definition"))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, set_opts("Lsp Hover"))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, set_opts("Lsp implementation"))
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, set_opts("Lsp signature help"))
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, set_opts("Lsp add workspace folder"))
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, set_opts("Lsp remove workspace folder"))
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, set_opts("Lsp list workspace folder"))
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, set_opts("Lsp type definition"))
        vim.keymap.set('n', '<leader>lrn', vim.lsp.buf.rename, set_opts("Lsp rename"))
        vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, set_opts("Lsp code action"))
        vim.keymap.set('n', '<leader>lre', vim.lsp.buf.references, set_opts("Lsp reference"))
        vim.keymap.set('n', '<leader>lf', function()
            vim.lsp.buf.format { async = true }
        end, set_opts("Lsp format"))
    end,
})

-- Additional Language Server Configuration (e.g., lua language server)
lspconfig.lua_ls.setup({
    capabilities = cmp_lsp_capabilities,
    on_attach = function(client, bufnr)
        -- Your custom on_attach function, if needed
        print("LSP server attached for Lua")
    end,
})
