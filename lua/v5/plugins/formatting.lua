-- conform.nvim setup
return {
  "stevearc/conform.nvim",
  ft = {
    "javascript",
    "typescript",
    "php",
    "html",
    "css",
    "scss",
    "lua",
    "bash",
    "sh",
    "tsx",
    "jsx",
    "yaml",
    "json",
    "markdown",
    "ruby",
  },
  keys = {
    {
      "<leader>mp",
      function()
        if vim.fn.mode():match("[vV]") then
          local s_pos = vim.fn.getpos("'<")
          local e_pos = vim.fn.getpos("'>")
          require("conform").format({
            range = {
              start = { s_pos[2], s_pos[3] - 1 },
              ["end"] = { e_pos[2], e_pos[3] - 1 },
            },
          })
        else
          require("conform").format()
        end
      end,
      mode = { "n", "v" },
      desc = "Format code or selected range",
    },
  },

  config = function()
    local conform = require("conform")

    -- Paths for global NVM Prettier and plugins
    -- local global_prettier = vim.fn.trim(vim.fn.system("which prettier"))
    local global_prettier = "/home/mzd/.config/nvm/versions/node/v24.11.0/bin/prettier"
    local fallback_config = vim.fn.expand("~/.prettierrc.json")

    local function has_local_prettier_config()
      local config_files = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        "prettier.config.js",
      }
      for _, file in ipairs(config_files) do
        if vim.loop.fs_stat(vim.loop.cwd() .. "/" .. file) then
          return true
        end
      end
      return false
    end

    conform.setup({
      formatters = {
        prettier_global = {
          command = global_prettier,
          args = function()
            local args = { "--stdin-filepath", "$FILENAME" }
            if not has_local_prettier_config() then
              table.insert(args, "--config")
              table.insert(args, fallback_config)
            end
            return args
          end,
          stdin = true,
        },
        rubocop_fix = {
          command = "rubocop",
          args = { "--stdin", "$FILENAME", "--auto-correct", "--format", "quiet" },
          stdin = true,
        },
        phpcbf_fix = {
          command = "phpcbf",
          args = { "$FILENAME" },
          stdin = false,
        },
        shfmt_fix = {
          command = "shfmt",
          args = { "-w", "$FILENAME" },
          stdin = false,
        },
        stylua_fix = {
          command = "stylua",
          args = { "--stdin-filepath", "$FILENAME", "-" },
          stdin = true,
        },
        beautysh_fix = {
          command = "beautysh",
          args = { "-s", "$FILENAME" },
          stdin = false,
        },
      },
      formatters_by_ft = {
        php = { "prettier_global", "phpcbf_fix" },
        ruby = { "prettier_global", "rubocop_fix" },
        sh = { "prettier_global", "shfmt_fix" },
        javascript = { "prettier_global" },
        typescript = { "prettier_global" },
        jsx = { "prettier_global" },
        tsx = { "prettier_global" },
        css = { "prettier_global" },
        scss = { "prettier_global" },
        html = { "prettier_global" },
        json = { "prettier_global" },
        markdown = { "prettier_global" },
        lua = { "stylua_fix" },
        bash = { "beautysh_fix" },
        zsh = { "beautysh_fix" },
        yaml = { "prettier_global" },
      },
      format_on_save = function(bufnr)
        if vim.g.format_on_save_enabled then
          return { timeout_ms = 3000, lsp_fallback = true }
        end
      end,
    })
  end,
}
