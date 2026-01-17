return {
  "stevearc/conform.nvim",
  -- lazy‑load on buffer read/new file
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<leader>mp",
      function()
        local conform = require("conform")
        -- Range format if selection
        if vim.fn.mode():match("[vV]") then
          local s_pos = vim.fn.getpos("'<")
          local e_pos = vim.fn.getpos("'>")
          conform.format({
            range = {
              start = { s_pos[2], s_pos[3] - 1 },
              ["end"] = { e_pos[2], e_pos[3] - 1 },
            },
          })
        else
          conform.format()
        end
      end,
      mode = { "n", "v" },
      desc = "Format code or selection",
    },
  },
  opts = {
    -- default behavior for any formatting call
    default_format_opts = {
      timeout_ms = 5000,
      lsp_format = "fallback", -- use LSP if no external formatter found
    },

    -- run formatter on save
    format_on_save = function(bufnr)
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      if ft == "ruby" then
        return nil -- disable autoformat on save for Ruby
      end

      return {
        timeout_ms = 5000,
        lsp_format = "fallback",
      }
    end,

    -- custom formatter definitions
    formatters = {
      -- If you want prettier to come from mason/node_modules
      prettier = {
        -- no need to override command if prettier is in PATH
        -- else set full path here
      },
      -- php formatter
      phpcbf = {
        command = "phpcbf",
        args = { "--standard=PSR12", "-" },
        stdin = true,
      },
      -- rubocop for Ruby
      rubocop = {
        command = "rubocop",
        args = { "--stdin", "$FILENAME", "--autocorrect", "--format", "quiet", "--stderr" },
        stdin = true,
      },
      -- shfmt
      shfmt = {
        command = "shfmt",
        append_args = { "-i", "2" },
        stdin = true,
      },
    },

    -- map filetypes to formatters
    formatters_by_ft = {
      -- Web languages: prefer prettierd, fallback to prettier
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      tsx = { "prettierd", "prettier", stop_after_first = true },
      jsx = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },

      -- PHP
      php = { "prettier", "phpcbf" },

      -- Ruby
      ruby = { "rubocop" },

      -- Shell
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },

      -- Lua
      lua = { "stylua" },
    },
  },
}
