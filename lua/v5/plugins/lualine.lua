return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "franco-ruggeri/codecompanion-lualine.nvim",
  },
  config = function()
    local lualine = require("lualine")
    local devicons = require("nvim-web-devicons")

    -- Safe Git branch: returns nil if not in a Git repo
    local function safe_git_branch()
      local ok, branch = pcall(function()
        return vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
      end)
      if ok and branch and branch ~= "" then
        return " " .. branch
      end
      return nil
    end

    -- Check if current buffer is in a Git repo
    local function in_git_repo()
      return vim.fn.isdirectory(".git") == 1
          or vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true") ~= nil
    end

    lualine.setup({
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true, -- single global statusline
        refresh = {
          statusline = 2000, -- increase refresh interval for performance
          tabline = 2000,
          winbar = 2000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { safe_git_branch, cond = in_git_repo },
          { "diff",          cond = in_git_repo },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_c = {
          {
            function()
              local filename = vim.fn.expand("%:t")
              if filename == "" then
                return "[No Name]"
              end

              local ext = vim.fn.expand("%:e")
              local icon, color = devicons.get_icon_color(filename, ext, { default = true })

              return string.format(" %s %s", icon, filename)
            end,
            color = function()
              local filename = vim.fn.expand("%:t")
              local ext = vim.fn.expand("%:e")
              local _, color = devicons.get_icon_color(filename, ext, { default = true })
              return { fg = color }
            end,
          },
        },
        lualine_x = {
          {
            function()
              if vim.fn.exists("*copilot#Enabled") == 1 and vim.fn["copilot#Enabled"]() == 1 then
                return " Copilot"
              end
              return ""
            end,
            color = { fg = "#50fa7b" },
          },
          "encoding",
          "fileformat",
          "filetype",
          {
            "filesize",
            cond = function()
              return vim.fn.getfsize(vim.fn.expand("%")) > 0
            end,
          },
        },
        lualine_y = {
          "progress",
          {
            "codecompanion",
            icon = " ",
            spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            done_symbol = "✓",
          },
        },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "quickfix", "toggleterm", "nvim-tree", "fugitive" },
    })
  end,
}
