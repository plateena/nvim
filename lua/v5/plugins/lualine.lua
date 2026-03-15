return {
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = {
    "franco-ruggeri/codecompanion-lualine.nvim",
  },
  config = function()
    local lualine = require("lualine")
    local devicons = require("nvim-web-devicons")

    lualine.setup({
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "nvimtree" },
          winbar = { "nvimtree" },
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
          { "branch" },
          { "diff", cond = in_git_repo },
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
              local buf = vim.api.nvim_get_current_buf()
              if not vim.b[buf].lualine_icon then
                local filename = vim.fn.expand("%:t")
                local ext = vim.fn.expand("%:e")
                local icon, color = devicons.get_icon_color(filename, ext, { default = true })
                vim.b[buf].lualine_icon = icon or ""
                vim.b[buf].lualine_color = color or "#ffffff"
              end

              local filename = vim.fn.expand("%:t")
              if filename == "" then
                filename = "[No Name]"
              end

              return string.format(" %s %s", vim.b[buf].lualine_icon, filename)
            end,
            color = function()
              local buf = vim.api.nvim_get_current_buf()
              return { fg = vim.b[buf].lualine_color or "#ffffff" }
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
