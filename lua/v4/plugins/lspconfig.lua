return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local capabilities = cmp_nvim_lsp.default_capabilities()

        mason_lspconfig.setup_handlers({
            function(server_name)
                local server_config = {}
                if server_name == "phpactor" then
                    server_config = {
                        capabilities = capabilities,
                        filetypes = { "php", "blade", "blade.php" },
                    }
                elseif server_name == "pylsp" then
                    server_config = {
                        settings = {
                            pylsp = {
                                plugins = {
                                    pycodestyle = {
                                        -- ignore = { "E501" },
                                        maxLineLength = 120,
                                    },
                                },
                            },
                        },
                    }
                elseif server_name == "yamlls" then
                    server_config = {
                        yaml = {
                            schemas = {
                                ["https://bitbucket.org/atlassianlabs/intellij-bitbucket-references-plugin/raw/master/src/main/resources/schemas/bitbucket-pipelines.schema.json"] = "/bitbucket.pipeline.yml",
                            },
                            schemaStore = {
                                enable = true,
                            },
                        },
                    }
                elseif server_name == "emmet_language_server" or server_name == "emmet_ls" then
                    server_config = {
                        capabilities = capabilities,
                        filetypes = {
                            "blade",
                            "css",
                            "eruby",
                            "html",
                            "javascript",
                            "javascriptreact",
                            "less",
                            "pug",
                            "sass",
                            "scss",
                            "typescriptreact",
                            "vue",
                        },
                    }
                else
                    server_config = {}
                end

                lspconfig[server_name].setup(server_config)
            end,
        })

        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            -- Enable underline, use default values
            underline = false,
            virtual_text = true,
            signs = true,
            update_in_insert = false,
        })

        local _border = "single"

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = _border,
        })

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = _border,
        })

        vim.diagnostic.config({
            float = { border = _border },
        })
        -- 
        local signs = { Error = "", Warn = " ", Hint = "", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set("n", "<space>lo", vim.diagnostic.open_float, { desc = "Diagnostic open float" })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic previous issue" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic next issue" })
        vim.keymap.set("n", "<space>lq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP Actions",
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local function setOpts(desc)
                    return {
                        desc = desc,
                        buffer = ev.buf,
                    }
                end

                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, setOpts("Lsp declaration"))
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, setOpts("Lsp definition"))
                vim.keymap.set("n", "K", vim.lsp.buf.hover, setOpts("Lsp Hover"))
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, setOpts("Lsp implimentation"))
                vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, setOpts("Lsp signature help"))
                -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, setOpts("Lsp add workspace folder"))
                -- vim.keymap.set(
                --     "n",
                --     "<space>wr",
                --     vim.lsp.buf.remove_workspace_folder,
                --     setOpts("Lsp remove workspace folder")
                -- )
                -- vim.keymap.set("n", "<space>wl", function()
                --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                -- end, setOpts("Lsp list workspace folder"))
                vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, setOpts("Lsp type definition"))
                vim.keymap.set("n", "<space>lrn", vim.lsp.buf.rename, setOpts("Lsp rename"))
                vim.keymap.set("n", "<space>la", vim.lsp.buf.code_action, setOpts("Lsp code action"))
                vim.keymap.set("n", "<space>lre", vim.lsp.buf.references, setOpts("Lsp reference"))
                vim.keymap.set("n", "<space>lf", function()
                    vim.lsp.buf.format({ async = true })
                end, setOpts("Lsp format"))
            end,
        })

        vim.keymap.set("n", "<leader>l", "", { desc = "LSP" })
    end,
}
