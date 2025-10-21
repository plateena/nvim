return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
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
        -- local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Constants
        local MAX_FILE_LINES = 5000
        local DIAGNOSTIC_ICONS = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
        }

        -- Enhanced capabilities
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
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    },
                },
            }
        )

        -- Server configurations
        local servers = {
            -- Web Development
            emmet_ls = {
                filetypes = {
                    "blade",
                    "css",
                    "ruby",
                    "html",
                    "javascript",
                    "javascriptreact",
                    "less",
                    "pug",
                    "sass",
                    "scss",
                    "svelte",
                    "typescriptreact",
                    "vue",
                },
            },

            -- JavaScript/TypeScript (Added for Node.js)
            ts_ls = {
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                settings = {
                    typescript = {
                        preferences = {
                            disableSuggestions = false,
                        },
                    },
                },
            },

            eslint = {
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                settings = {
                    workingDirectory = { mode = "auto" },
                },
            },

            -- Prettier for formatting (JavaScript, TypeScript, JSON, etc.)
            -- Note: This requires null-ls or conform.nvim for formatting integration
            -- Alternative: Use prettier via external tools or null-ls

            -- PHP/Laravel
            phpactor = {
                filetypes = { "php", "blade", "blade.php" },
                root_dir = vim.fs.root(0,{"composer.json", ".git"}),
                init_options = {
                    ["language_server_phpstan.enabled"] = true,
                    ["language_server_psalm.enabled"] = false,
                },
            },

            -- Alternative PHP LSP (uncomment if preferred)
            -- intelephense = {
            --     filetypes = { "php", "blade" },
            --     settings = {
            --         intelephense = {
            --             files = {
            --                 maxSize = 1000000,
            --             },
            --         },
            --     },
            -- },

            -- Ruby
            ruby_lsp = {
                cmd = { "ruby-lsp" },
                root_dir = vim.fs.root(0, {"Gemfile", ".git"}),
                init_options = {
                    formatter = "rubocop",
                },
            },

            rubocop = {
                cmd = { "rubocop", "--lsp" },
                root_dir = vim.fs.root(0, {".rubocop.yml", "Gemfile", ".git"}),
            },

            -- Lua
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = {
                            globals = { "vim", "describe", "it", "before_each", "after_each" }, -- Added test globals
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            },

            -- Python
            pylsp = {
                settings = {
                    pylsp = {
                        plugins = {
                            pycodestyle = {
                                maxLineLength = 120,
                                ignore = { "E203", "W503" }, -- Black compatibility
                            },
                            pylint = { enabled = true },
                            autopep8 = { enabled = false }, -- Prefer black
                            black = { enabled = true },
                            isort = { enabled = true },
                        },
                    },
                },
            },

            -- YAML
            yamlls = {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
                            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.{yml,yaml}",
                            ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.1/schema.json"] =
                            "/openapi*.{yml,yaml}",
                        },
                        schemaStore = {
                            enable = true,
                            url = "https://www.schemastore.org/api/json/catalog.json",
                        },
                    },
                },
            },

            -- Bash
            bashls = {
                filetypes = { "sh", "bash" },
            },

            -- JSON
            jsonls = {
                settings = {
                    json = {
                        schemas = {
                            {
                                fileMatch = { "package.json" },
                                url = "https://json.schemastore.org/package.json",
                            },
                            {
                                fileMatch = { "composer.json" },
                                url = "https://json.schemastore.org/composer.json",
                            },
                            {
                                fileMatch = { ".eslintrc.json", ".eslintrc" },
                                url = "https://json.schemastore.org/eslintrc.json",
                            },
                            {
                                fileMatch = { "tsconfig.json", "tsconfig.*.json" },
                                url = "https://json.schemastore.org/tsconfig.json",
                            },
                        },
                        validate = { enable = true },
                    },
                },
            },
        }

        -- Improved on_attach function
        local on_attach = function(client, bufnr)
            -- Performance check
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count >= MAX_FILE_LINES then
                client.stop()
                vim.notify(
                    string.format(
                        "LSP '%s' disabled: file has %d lines (limit: %d)",
                        client.name,
                        line_count,
                        MAX_FILE_LINES
                    ),
                    vim.log.levels.WARN
                )
                return
            end

            -- Disable semantic tokens for large files if supported
            if line_count > 1000 and client.server_capabilities then
                if client.server_capabilities.semanticTokensProvider then
                    client.server_capabilities.semanticTokensProvider = nil
                end
            end

            -- Helper function for keymaps
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr, silent = true })
            end

            -- Navigation
            map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
            map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
            map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
            map("n", "gr", vim.lsp.buf.references, "LSP: Show references")
            map("n", "<space>lD", vim.lsp.buf.type_definition, "LSP: Type definition")

            -- Documentation
            map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
            map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")
            map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help")

            -- Code actions
            map("n", "<space>la", vim.lsp.buf.code_action, "LSP: Code action")
            map("v", "<space>la", vim.lsp.buf.code_action, "LSP: Code action")
            map("n", "<space>lrn", vim.lsp.buf.rename, "LSP: Rename")

            -- Formatting
            if client:supports_method("textDocument/formatting") then
                map({ "n", "v" }, "<space>lf", function()
                    vim.lsp.buf.format({
                        async = true,
                        filter = function(c)
                            -- Prefer certain formatters
                            local preferred = { "null-ls", "conform", "prettier", "eslint", "rubocop" }
                            for _, name in ipairs(preferred) do
                                if c.name == name then
                                    return true
                                end
                            end
                            return c.name == client.name
                        end,
                    })
                end, "LSP: Format")

                -- Auto-format on save for specific filetypes
                local format_on_save_ft = { "lua", "javascript", "typescript", "php" }
                if vim.g.format_on_save_enabled and vim.tbl_contains(format_on_save_ft, vim.bo[bufnr].filetype) then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                        end,
                    })
                end
            end

            -- Diagnostics
            map("n", "<space>lo", vim.diagnostic.open_float, "LSP: Show diagnostics")
            map("n", "[d", vim.diagnostic.goto_prev, "LSP: Previous diagnostic")
            map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic")
            map("n", "<space>lq", vim.diagnostic.setloclist, "LSP: Diagnostic quickfix")

            -- Testing keymaps (for TDD workflow)
            if vim.bo[bufnr].filetype == "ruby" then
                map("n", "<space>tt", ":!bundle exec rspec %<CR>", "Test: Run current file")
                map("n", "<space>tl", ":!bundle exec rspec %:" .. vim.fn.line(".") .. "<CR>", "Test: Run current line")
            elseif vim.bo[bufnr].filetype == "javascript" or vim.bo[bufnr].filetype == "typescript" then
                map("n", "<space>tt", ":!npm test %<CR>", "Test: Run current file")
            elseif vim.bo[bufnr].filetype == "php" then
                map("n", "<space>tt", ":!./vendor/bin/phpunit %<CR>", "Test: Run current file")
            end

            -- Document highlight
            if client.supports_method("textDocument/documentHighlight") then
                vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
                vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "lsp_document_highlight" })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group = "lsp_document_highlight",
                    buffer = bufnr,
                    callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    group = "lsp_document_highlight",
                    buffer = bufnr,
                    callback = vim.lsp.buf.clear_references,
                })
            end

            -- Create LSP which-key group
            if pcall(require, "which-key") then
                require("which-key").add({
                    { "<space>l", group = "LSP" },
                    { "<space>t", group = "Test" },
                })
            end
        end

        -- Setup servers
            for name, opts in pairs(servers) do
                opts.capabilities = capabilities
                opts.on_attach = on_attach

                local ok, err = pcall(function()
                    vim.lsp.config[name] = opts
                    vim.lsp.enable(name)
                end)

                if not ok then
                    vim.notify(string.format("Failed to enable LSP server '%s': %s", name, err), vim.log.levels.ERROR)
                end
            end

        -- Enhanced diagnostic configuration
        vim.diagnostic.config({
            underline = false,
            virtual_text = {
                spacing = 4,
                prefix = "●",
                current_line = true,
                format = function(diagnostic)
                    return string.format("%s (%s)", diagnostic.message, diagnostic.source)
                end,
            },
            signs = {
                text = DIAGNOSTIC_ICONS,
            },
            update_in_insert = false,
            severity_sort = true,
            float = {
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
                format = function(diagnostic)
                    return string.format(
                        "%s (%s) [%s]",
                        diagnostic.message,
                        diagnostic.source or "unknown",
                        diagnostic.code or "no-code"
                    )
                end,
            },
        })

        -- Global LSP keymaps
        vim.keymap.set("n", "<space>li", "<cmd>LspInfo<cr>", { desc = "LSP: Info" })
        vim.keymap.set("n", "<space>lr", "<cmd>LspRestart<cr>", { desc = "LSP: Restart" })

        -- Improved updatetime for better responsiveness
        vim.o.updatetime = 300

        -- Optional: Show diagnostics automatically in hover window
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
