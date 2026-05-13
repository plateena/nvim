-- Built-in LSP configuration (not managed by Lazy.nvim)

local function setup_lsp()
  local ok, blink = pcall(require, "blink.cmp")
  local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

  capabilities = vim.tbl_deep_extend("force", capabilities, {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
    textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
  })

  local MAX_FILE_LINES = 5000
  local DIAGNOSTIC_ICONS = {
    [vim.diagnostic.severity.ERROR] = "✘",
    [vim.diagnostic.severity.WARN] = "▲",
    [vim.diagnostic.severity.HINT] = "⚑",
    [vim.diagnostic.severity.INFO] = "»",
  }

  local function map(mode, lhs, rhs, desc, bufnr)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr, silent = true })
  end

  local on_attach = function(client, bufnr)
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count >= MAX_FILE_LINES then
      client:stop()
      vim.notify(string.format("LSP '%s' disabled: %d lines (limit: %d)", client.name, line_count, MAX_FILE_LINES), vim.log.levels.WARN)
      return
    end

    if line_count > 1000 and client.server_capabilities and client.server_capabilities.semanticTokensProvider then
      client.server_capabilities.semanticTokensProvider = nil
    end

    -- Navigation
    map("n", "gD", vim.lsp.buf.declaration, "LSP: Declaration", bufnr)
    map("n", "gd", vim.lsp.buf.definition, "LSP: Definition", bufnr)
    map("n", "gi", vim.lsp.buf.implementation, "LSP: Implementation", bufnr)
    map("n", "gr", vim.lsp.buf.references, "LSP: References", bufnr)
    map("n", "<space>lD", vim.lsp.buf.type_definition, "LSP: Type definition", bufnr)

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "LSP: Hover", bufnr)
    map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help", bufnr)
    map("i", "<C-h>", vim.lsp.buf.signature_help, "LSP: Signature help", bufnr)

    -- Code actions
    map("n", "<space>la", vim.lsp.buf.code_action, "LSP: Code action", bufnr)
    map("v", "<space>la", vim.lsp.buf.code_action, "LSP: Code action", bufnr)
    map("n", "<space>lrn", vim.lsp.buf.rename, "LSP: Rename", bufnr)

    -- Formatting (via LSP fallback)
    if client:supports_method("textDocument/formatting") then
      map({ "n", "v" }, "<space>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: Format", bufnr)
    end

    -- Diagnostics
    map("n", "<space>lo", vim.diagnostic.open_float, "LSP: Diagnostics float", bufnr)
    map("n", "[d", vim.diagnostic.goto_prev, "LSP: Prev diagnostic", bufnr)
    map("n", "]d", vim.diagnostic.goto_next, "LSP: Next diagnostic", bufnr)
    map("n", "<space>lq", vim.diagnostic.setloclist, "LSP: Diagnostic loclist", bufnr)

    -- Testing keymaps
    local ft = vim.bo[bufnr].filetype
    if ft == "ruby" then
      map("n", "<space>tt", ":!bundle exec rspec %<CR>", "Test: Run file", bufnr)
      map("n", "<space>tl", ":!bundle exec rspec %:" .. vim.fn.line(".") .. "<CR>", "Test: Run line", bufnr)
    elseif ft == "javascript" or ft == "typescript" then
      map("n", "<space>tt", ":!npm test %<CR>", "Test: Run file", bufnr)
    elseif ft == "php" then
      map("n", "<space>tt", ":!./vendor/bin/phpunit %<CR>", "Test: Run file", bufnr)
    elseif ft == "python" then
      map("n", "<space>tt", ":!python -m pytest %<CR>", "Test: Run file", bufnr)
    end

    -- Document highlight
    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group, buffer = bufnr, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group, buffer = bufnr, callback = vim.lsp.buf.clear_references,
      })
    end
  end

  -- LSP servers
  local servers = {
    tsserver = {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    },
    ruby_lsp = {
      cmd = { "docker", "run", "--rm", "-i", "-v", vim.loop.cwd() .. ":/workspace", "ruby-lsp:3.0.4" },
      filetypes = { "ruby" },
      root_dir = function()
        local f = vim.fs.find({ "Gemfile", ".git" }, { upward = true })
        return f[1] and vim.fs.dirname(f[1]) or nil
      end,
      init_options = { formatter = "rubocop" },
    },
    lua_ls = {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim", "Snacks" } },
          workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    },
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
    },
    phpactor = {
      cmd = { "phpactor", "language-server" },
      filetypes = { "php", "blade", "blade.php" },
      root_dir = function()
        local f = vim.fs.find({ "composer.json", ".git" }, { upward = true })
        return f[1] and vim.fs.dirname(f[1]) or nil
      end,
      init_options = { ["language_server_phpstan.enabled"] = true, ["language_server_psalm.enabled"] = false },
    },
    bashls = {
      cmd = { "bash-language-server", "start" },
      filetypes = { "sh", "bash", "zsh" },
    },
    emmet_ls = {
      cmd = { "emmet-ls", "--stdio" },
      filetypes = { "html", "css", "scss", "blade", "php", "javascriptreact", "typescriptreact" },
    },
    tailwindcss = {
      cmd = { "tailwindcss-language-server", "--stdio" },
      filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "blade", "php" },
      root_dir = function()
        local f = vim.fs.find({ "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs" }, { upward = true })
        return f[1] and vim.fs.dirname(f[1]) or nil
      end,
    },
  }

  -- Start LSP servers via FileType autocmds
  for name, opts in pairs(servers) do
    for _, ft in ipairs(opts.filetypes or {}) do
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft,
        callback = function(args)
          if #vim.lsp.get_clients({ name = name, bufnr = args.buf }) > 0 then return end
          vim.lsp.start({
            name = name,
            cmd = opts.cmd,
            root_dir = type(opts.root_dir) == "function" and opts.root_dir() or opts.root_dir,
            capabilities = capabilities,
            on_attach = on_attach,
            settings = opts.settings,
            init_options = opts.init_options,
            single_file_support = true,
          })
        end,
      })
    end
  end

  -- Diagnostics config
  vim.diagnostic.config({
    underline = false,
    virtual_text = { spacing = 4, prefix = "●", current_line = true },
    signs = { text = DIAGNOSTIC_ICONS },
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = true },
  })

  -- Global LSP keymaps
  vim.keymap.set("n", "<space>lci", function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then print("No active LSP clients") return end
    for _, c in ipairs(clients) do print(string.format("  - %s (id: %d)", c.name, c.id)) end
  end, { desc = "LSP: Info" })

  vim.keymap.set("n", "<space>lcr", function()
    for _, c in ipairs(vim.lsp.get_clients()) do c:stop() end
    vim.cmd("edit")
    print("LSP clients restarted")
  end, { desc = "LSP: Restart" })

  vim.api.nvim_create_user_command("LspInfo", function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then print("No active LSP clients") return end
    for _, c in ipairs(clients) do
      print(string.format("  %s (id:%d) root:%s", c.name, c.id, c.root_dir or "none"))
    end
  end, {})

  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("edit " .. vim.lsp.get_log_path())
  end, {})

  vim.o.updatetime = 300
end

vim.defer_fn(setup_lsp, 100)
