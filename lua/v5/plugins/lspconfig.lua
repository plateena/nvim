return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
        {
            "j-hui/fidget.nvim",
            opts = {
                notification = {
                    window = {
                        normal_hl = "Comment",
                        winblend = 0,
                        border = "none",
                    },
                },
            },
        },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_nvim_lsp.default_capabilities(),
            {
                workspace = {
                    didChangeWatchedFiles = {
                        dynamicRegistration = true,
                    },
                },
            }
        )

        local servers = {
            emmet_ls = {
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
            },
            lua_ls = {
                cmd = { "lua-language-server" },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            },
            phpactor = {
                filetypes = { "php", "blade", "blade.php" },
                root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
            },
            pylsp = {
                settings = {
                    pylsp = {
                        plugins = {
                            pycodestyle = {
                                maxLineLength = 120,
                            },
                            pylint = { enabled = true },
                            autopep8 = { enabled = true },
                        },
                    },
                },
            },
            ruby_lsp = {
                cmd = { "ruby", "-S", "ruby-lsp" },
                root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
            },
            rubocop = {
                cmd = { "rubocop", "--lsp" },
            },
            yamlls = {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
                            ["https://bitbucket.org/atlassianlabs/intellij-bitbucket-references-plugin/raw/master/src/main/resources/schemas/bitbucket-pipelines.schema.json"] = "/bitbucket.pipeline.yml",
                        },
                        schemaStore = {
                            enable = true,
                            url = "https://www.schemastore.org/api/json/catalog.json",
                        },
                    },
                },
            },
        }

        local on_attach = function(client, bufnr, max_lines)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            max_lines = max_lines or 1000
            if line_count >= max_lines then
                client.stop()
                vim.notify(
                    string.format(
                        "LSP '%s' disabled: file has %d lines (limit: %d)",
                        client.name,
                        line_count,
                        max_lines
                    ),
                    vim.log.levels.INFO
                )
                return
            end

            local function setOpts(desc)
                return { desc = desc, buffer = bufnr }
            end

            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, setOpts("Lsp declaration"))
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, setOpts("Lsp definition"))
            vim.keymap.set("n", "K", vim.lsp.buf.hover, setOpts("Lsp hover"))
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, setOpts("Lsp implementation"))
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, setOpts("Lsp signature help"))
            vim.keymap.set("n", "<space>lD", vim.lsp.buf.type_definition, setOpts("Lsp type definition"))
            vim.keymap.set("n", "<space>lrn", vim.lsp.buf.rename, setOpts("Lsp rename"))
            vim.keymap.set("n", "<space>la", vim.lsp.buf.code_action, setOpts("Lsp code action"))
            vim.keymap.set("n", "<space>lre", vim.lsp.buf.references, setOpts("Lsp reference"))
            vim.keymap.set({ "n", "v" }, "<space>lf", function()
                vim.lsp.buf.format({ async = true })
            end, setOpts("Lsp format"))
            vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, setOpts("Lsp signature help"))
            vim.keymap.set("n", "<leader>l", "", { desc = "LSP" })
        end

        for name, opts in pairs(servers) do
            opts.capabilities = capabilities
            opts.on_attach = on_attach
            -- Graceful error handling
            local ok, err = pcall(function()
                lspconfig[name].setup(opts)
            end)

            if not ok then
                vim.notify(string.format("Failed to setup LSP server %s: %s", name, err), vim.log.levels.ERROR)
            end
        end

        vim.diagnostic.config({
            underline = false,
            -- virtual_text = {
            --     prefix = "■",
            --     source = true,
            -- },
            virtual_text = false,
            signs = {
                text = {
                    -- [vim.diagnostic.severity.ERROR] = "",
                    -- [vim.diagnostic.severity.WARN] = " ",
                    -- [vim.diagnostic.severity.HINT] = "",
                    -- [vim.diagnostic.severity.INFO] = " ",
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»",
                },
            },
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                source = true,
                header = "LSP Diagnostic",
                prefix = "",
            },
        })

        vim.keymap.set("n", "<space>lo", vim.diagnostic.open_float, { desc = "Diagnostic open float" })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostic previous issue" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostic next issue" })
        vim.keymap.set("n", "<space>lq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

        vim.o.updatetime = 250
        -- vim.api.nvim_create_autocmd("CursorHold", {
        --     callback = function()
        --         local opts = {
        --             focusable = false,
        --             close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        --             border = "rounded",
        --             source = "always",
        --             prefix = " ",
        --             scope = "cursor",
        --         }
        --         vim.diagnostic.open_float(nil, opts)
        --     end,
        -- })
    end,
}
