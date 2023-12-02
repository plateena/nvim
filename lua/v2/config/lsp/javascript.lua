-- Install the following npm package globally:
-- npm install -g typescript-language-server

-- LSP configuration for Node.js
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.tsserver.setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        -- Your custom on_attach function, if needed
        print("LSP server attached for Node.js")
    end,
})
