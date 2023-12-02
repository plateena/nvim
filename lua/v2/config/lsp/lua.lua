local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Specify the version of Lua you're using (LuaJIT for Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Allow the language server to recognize certain globals
                globals = { "vim" },
            },
            workspace = {
                -- Include Neovim runtime files for better awareness
                -- library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                -- Disable sending telemetry data with a unique identifier
                enable = false,
            },
        },
    },
})
