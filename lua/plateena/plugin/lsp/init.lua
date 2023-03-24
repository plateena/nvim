vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Enable underline, use default values
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = false,
    }
)

local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = _border
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
        border = _border
    }
)

vim.diagnostic.config {
    float = { border = _border }
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end


-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>lo', vim.diagnostic.open_float, { desc = "Diagnostic open float" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Diagnostic previous issue" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Diagnostic next issue" })
vim.keymap.set('n', '<space>lq', vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
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
        vim.keymap.set('n', 'lre', vim.lsp.buf.references, setOpts("Lsp reference"))
        vim.keymap.set('n', '<space>lf', function()
            vim.lsp.buf.format { async = true }
        end, setOpts("Lsp format"))
    end,
})

require 'lspconfig'.lua_ls.setup {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

require("mason").setup({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup({
    automatic_installation = false
})

local lspconfig = require('lspconfig')
-- local configs = require('lspconfig/configs')
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.lua_ls.setup {
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

lspconfig.emmet_ls.setup({
    capabilities = capabilities,
    filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
    init_options = {
        html = {
            options = {
                -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
                ["bem.enabled"] = true,
            },
        },
    }
})

lspconfig.phpactor.setup({
    capabilities = capabilities,
})
