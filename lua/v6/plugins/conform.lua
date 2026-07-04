return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>mp", function() require("conform").format() end, mode = { "n", "v" }, desc = "Format code" },
  },
  config = function()
    require("conform").setup({
      default_format_opts = { timeout_ms = 5000, lsp_format = "fallback" },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "ruby" then return nil end
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local wiki = vim.fn.expand(vim.g.wiki_root or "~/Documents/wiki")
        if bufname:find(wiki, 1, true) then return nil end
        return { timeout_ms = 5000, lsp_format = "fallback" }
      end,
      formatters = {
        phpcbf = { command = "phpcbf", args = { "--standard=PSR12", "-" }, stdin = true },
        shfmt = { command = "shfmt", append_args = { "-i", "2" }, stdin = true },
      },
      formatters_by_ft = {
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
        php = { "phpcbf" },
        ruby = { "rubocop" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        lua = { "stylua" },
      },
    })
  end,
}
