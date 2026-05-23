-- Built-in LSP configuration for Neovim 0.12+

local function setup_lsp()
  local ok, blink = pcall(require, "blink.cmp")

  local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

  capabilities = vim.tbl_deep_extend("force", capabilities, {
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
  })

  local MAX_FILE_LINES = 5000

  local DIAGNOSTIC_ICONS = {
    [vim.diagnostic.severity.ERROR] = "✘",
    [vim.diagnostic.severity.WARN] = "▲",
    [vim.diagnostic.severity.HINT] = "⚑",
    [vim.diagnostic.severity.INFO] = "»",
  }

  local function map(mode, lhs, rhs, desc, bufnr)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = bufnr,
      desc = desc,
      silent = true,
    })
  end

  local on_attach = function(client, bufnr)
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    if line_count >= MAX_FILE_LINES then
      client:stop()
      vim.notify(
        string.format("LSP '%s' disabled: %d lines (limit: %d)", client.name, line_count, MAX_FILE_LINES),
        vim.log.levels.WARN
      )
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
    map("n", "gy", vim.lsp.buf.type_definition, "LSP: Type Definition", bufnr)

    -- Info
    map("n", "K", vim.lsp.buf.hover, "LSP: Hover", bufnr)
    map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature", bufnr)
    map("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature", bufnr)

    -- Actions
    map("n", "<leader>la", vim.lsp.buf.code_action, "LSP: Code Action", bufnr)
    map("v", "<leader>la", vim.lsp.buf.code_action, "LSP: Code Action", bufnr)
    map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: Rename", bufnr)

    if client:supports_method("textDocument/formatting") then
      map("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: Format", bufnr)
    end

    -- Diagnostics
    map("n", "<leader>lo", vim.diagnostic.open_float, "Diagnostic float", bufnr)
    map("n", "[d", function() vim.diagnostic.goto_prev() vim.cmd("normal! zz") end, "Prev Diagnostic", bufnr)
    map("n", "]d", function() vim.diagnostic.goto_next() vim.cmd("normal! zz") end, "Next Diagnostic", bufnr)
    map("n", "<leader>ld", function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, "Toggle diagnostics", bufnr)

    -- Symbols (via snacks picker if available)
    map("n", "<leader>ls", function()
      local has_snacks, _ = pcall(require, "snacks")
      if has_snacks then
        Snacks.picker.lsp_symbols()
      else
        vim.lsp.buf.document_symbol()
      end
    end, "LSP: Document Symbols", bufnr)
    map("n", "<leader>lS", function()
      local has_snacks, _ = pcall(require, "snacks")
      if has_snacks then
        Snacks.picker.lsp_workspace_symbols()
      else
        vim.lsp.buf.workspace_symbol()
      end
    end, "LSP: Workspace Symbols", bufnr)

    -- Inlay hints
    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<leader>li", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, "Toggle inlay hints", bufnr)
    end

    -- Document highlight
    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if client then
        on_attach(client, args.buf)
      end
    end,
  })

  local servers = {
    lua_ls = {
      cmd = { "lua-language-server" },

      filetypes = { "lua" },

      root_dir = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.find({
          ".luarc.json",
          ".luarc.jsonc",
          ".git",
        }, {
          upward = true,
          path = vim.fs.dirname(path),
        })[1]

        return root and vim.fs.dirname(root) or vim.loop.cwd()
      end,

      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },

          diagnostics = {
            globals = { "vim", "Snacks" },
          },

          hint = {
            enable = true,
          },

          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },

          telemetry = {
            enable = false,
          },
        },
      },
    },

    tsserver = {
      cmd = { "typescript-language-server", "--stdio" },

      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },

      root_dir = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.find({
          "package.json",
          "tsconfig.json",
          ".git",
        }, {
          upward = true,
          path = vim.fs.dirname(path),
        })[1]

        return root and vim.fs.dirname(root) or vim.loop.cwd()
      end,
    },

    phpactor = {
      cmd = { "phpactor", "language-server" },

      filetypes = {
        "php",
      },

      root_dir = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.find({
          "composer.json",
          ".git",
        }, {
          upward = true,
          path = vim.fs.dirname(path),
        })[1]

        return root and vim.fs.dirname(root) or vim.loop.cwd()
      end,
    },

    pylsp = {
      cmd = { "pylsp" },

      filetypes = {
        "python",
      },

      root_dir = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.find({
          "pyproject.toml",
          "requirements.txt",
          ".git",
        }, {
          upward = true,
          path = vim.fs.dirname(path),
        })[1]

        return root and vim.fs.dirname(root) or vim.loop.cwd()
      end,
    },

    bashls = {
      cmd = { "bash-language-server", "start" },

      filetypes = {
        "sh",
        "bash",
        "zsh",
      },

      root_dir = function(bufnr)
        local path = vim.api.nvim_buf_get_name(bufnr)

        local root = vim.fs.find({
          ".git",
        }, {
          upward = true,
          path = vim.fs.dirname(path),
        })[1]

        return root and vim.fs.dirname(root) or vim.loop.cwd()
      end,
    },
  }

  for name, opts in pairs(servers) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = opts.filetypes,

      callback = function(args)
        if #vim.lsp.get_clients({
          name = name,
          bufnr = args.buf,
        }) > 0 then
          return
        end

        local root_dir = opts.root_dir

        if type(root_dir) == "function" then
          root_dir = root_dir(args.buf)
        end

        vim.lsp.start({
          name = name,
          cmd = opts.cmd,
          root_dir = root_dir,
          capabilities = capabilities,
          settings = opts.settings,
          init_options = opts.init_options,
          single_file_support = true,
        })
      end,
    })
  end

  vim.diagnostic.config({
    underline = false,

    virtual_text = {
      spacing = 4,
      prefix = "●",
      current_line = true,
    },

    signs = {
      text = DIAGNOSTIC_ICONS,
    },

    update_in_insert = false,
    severity_sort = true,

    float = {
      border = "rounded",
      source = true,
    },
  })

  vim.api.nvim_create_user_command("LspInfo", function()
    local clients = vim.lsp.get_clients()

    if #clients == 0 then
      print("No active LSP clients")
      return
    end

    for _, client in ipairs(clients) do
      print(string.format("%s (id:%d) root:%s", client.name, client.id, client.root_dir or "none"))
    end
  end, {})

  vim.api.nvim_create_user_command("LspRestart", function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      client:stop()
    end

    vim.cmd("edit")

    print("LSP restarted")
  end, {})

  vim.o.updatetime = 300
end

vim.api.nvim_create_autocmd("FileType", {
  once = true,
  callback = setup_lsp,
})
