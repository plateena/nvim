-- Built-in LSP configuration (not managed by Lazy.nvim)

-- Load dependencies only when needed
local function setup_lsp()
    local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if not cmp_nvim_lsp_ok then
        vim.notify("cmp_nvim_lsp not available", vim.log.levels.WARN)
        return
    end

    -- Constants
    local MAX_FILE_LINES = 5000
    local DIAGNOSTIC_ICONS = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "▲",
        [vim.diagnostic.severity.HINT] = "⚑",
        [vim.diagnostic.severity.INFO] = "»",
    }

    -- Capabilities
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

    -- Helper function for keymaps
    local function map(mode, lhs, rhs, desc, bufnr)
        vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr, silent = true })
    end

    -- on_attach
    local on_attach = function(client, bufnr)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if line_count >= MAX_FILE_LINES then
            client:stop() -- FIXED: Use colon syntax
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

        if line_count > 1000 and client.server_capabilities and client.server_capabilities.semanticTokensProvider then
            client.server_capabilities.semanticTokensProvider = nil
        end

        -- Navigation
        map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration", bufnr)
        map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition", bufnr)
        map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation", bufnr)
        map("n", "gr", vim.lsp.buf.references, "LSP: Show references", bufnr)
        map("n", "<space>lD", vim.lsp.buf.type_definition, "LSP: Type definition", bufnr)

        -- Documentation
        map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation", bufnr)
        map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help", bufnr)
        map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help", bufnr)

        -- Code actions
        map("n", "<space>la", vim.lsp.buf.code_action, "LSP: Code action", bufnr)
        map("v", "<space>la", vim.lsp.buf.code_action, "LSP: Code action", bufnr)
        map("n", "<space>lrn", vim.lsp.buf.rename, "LSP: Rename", bufnr)

        -- Formatting
        if client:supports_method("textDocument/formatting") then
            map({ "n", "v" }, "<space>lf", function()
                vim.lsp.buf.format({
                    async = true,
                    filter = function(c)
                        local preferred = { "null-ls", "conform", "prettier", "eslint", "rubocop" }
                        for _, name in ipairs(preferred) do
                            if c.name == name then
                                return true
                            end
                        end
                        return c.name == client.name
                    end,
                })
            end, "LSP: Format", bufnr)

            local format_on_save_ft = { "lua", "javascript", "typescript", "php", "ruby" }
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
        map("n", "<space>lo", vim.diagnostic.open_float, "LSP: Show diagnostics", bufnr)
        map("n", "[d", vim.diagnostic.goto_prev, "LSP: Previous diagnostic", bufnr)
        map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic", bufnr)
        map("n", "<space>lq", vim.diagnostic.setloclist, "LSP: Diagnostic quickfix", bufnr)

        -- Testing keymaps
        local ft = vim.bo[bufnr].filetype
        if ft == "ruby" then
            map("n", "<space>tt", ":!bundle exec rspec %<CR>", "Test: Run current file", bufnr)
            map(
                "n",
                "<space>tl",
                ":!bundle exec rspec %:" .. vim.fn.line(".") .. "<CR>",
                "Test: Run current line",
                bufnr
            )
        elseif ft == "javascript" or ft == "typescript" then
            map("n", "<space>tt", ":!npm test %<CR>", "Test: Run current file", bufnr)
        elseif ft == "php" then
            map("n", "<space>tt", ":!./vendor/bin/phpunit %<CR>", "Test: Run current file", bufnr)
        end

        -- Document highlight
        if client:supports_method("textDocument/documentHighlight") then
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

        -- Which-key groups
        if pcall(require, "which-key") then
            require("which-key").add({
                { "<space>l", group = "LSP" },
                { "<space>t", group = "Test" },
            })
        end
    end

    -- LSP servers configuration using BUILT-IN LSP
    local servers = {
        -- Ruby LSP
        ruby_lsp = {
            cmd = {
                "docker",
                "run",
                "--rm",
                "-i",
                "-v",
                vim.loop.cwd() .. ":/workspace",
                "ruby-lsp:3.0.4",
            },
            filetypes = { "ruby" },
            root_dir = function()
                local root_files = vim.fs.find({ "Gemfile", ".git" }, { upward = true })
                return root_files[1] and vim.fs.dirname(root_files[1]) or nil
            end,
            init_options = { formatter = "rubocop" },
            single_file_support = true,
        },

        -- Lua
        lua_ls = {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
            single_file_support = true,
        },

        -- Python
        pylsp = {
            cmd = { "pylsp" },
            filetypes = { "python" },
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = { maxLineLength = 120, ignore = { "E203", "W503" } },
                        pylint = { enabled = true },
                        black = { enabled = true },
                        isort = { enabled = true },
                    },
                },
            },
            single_file_support = true,
        },

        -- PHP
        phpactor = {
            cmd = { "phpactor", "language-server" },
            filetypes = { "php", "blade", "blade.php" },
            root_dir = function()
                local root_files = vim.fs.find({ "composer.json", ".git" }, { upward = true })
                return root_files[1] and vim.fs.dirname(root_files[1]) or nil
            end,
            init_options = { ["language_server_phpstan.enabled"] = true, ["language_server_psalm.enabled"] = false },
            single_file_support = true,
        },
    }

    -- Configure LSP servers using the MODERN built-in API
    for name, opts in pairs(servers) do
        opts.capabilities = capabilities
        opts.on_attach = on_attach

        -- Use vim.lsp.start for each file type with autocmd
        for _, ft in ipairs(opts.filetypes or {}) do
            vim.api.nvim_create_autocmd("FileType", {
                pattern = ft,
                callback = function(args)
                    -- Check if LSP is already attached to avoid duplicates
                    local existing_clients = vim.lsp.get_clients({ name = name, bufnr = args.buf })
                    if #existing_clients > 0 then
                        return
                    end

                    -- Start the LSP client
                    vim.lsp.start({
                        name = name,
                        cmd = opts.cmd,
                        root_dir = type(opts.root_dir) == "function" and opts.root_dir() or opts.root_dir,
                        capabilities = opts.capabilities,
                        on_attach = opts.on_attach,
                        settings = opts.settings,
                        init_options = opts.init_options,
                        single_file_support = opts.single_file_support,
                    })
                end,
            })
        end
    end

    -- Diagnostics
    vim.diagnostic.config({
        underline = false,
        virtual_text = { spacing = 4, prefix = "●", current_line = true },
        signs = { text = DIAGNOSTIC_ICONS },
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
    })

    -- Global LSP keymaps (using built-in functions since nvim-lspconfig is removed)
    vim.keymap.set("n", "<space>li", function()
        local clients = vim.lsp.get_clients()
        if #clients == 0 then
            print("No active LSP clients")
        else
            print("Active LSP clients:")
            for _, client in ipairs(clients) do
                print(string.format("  - %s (id: %d)", client.name, client.id))
            end
        end
    end, { desc = "LSP: Info" })

    vim.keymap.set("n", "<space>lr", function()
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
            client:stop()
        end
        vim.cmd("edit")
        print("LSP clients restarted")
    end, { desc = "LSP: Restart" })

    vim.o.updatetime = 300
end

-- Delay LSP setup to ensure plugins are loaded
vim.defer_fn(function()
    setup_lsp()
end, 100)
