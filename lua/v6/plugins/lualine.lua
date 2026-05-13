return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    local lualine = require("lualine")
    local MiniIcons = require("mini.icons")

    lualine.setup({
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = { "snacks_dashboard" },
          winbar = {},
        },
        globalstatus = true,
        refresh = {
          statusline = 2000,
          tabline = 2000,
          winbar = 2000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch" },
          { "diff" },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
        },
        lualine_c = {
          {
            function()
              local buf = vim.api.nvim_get_current_buf()
              if not vim.b[buf].lualine_icon then
                local filename = vim.fn.expand("%:t")
                local ext = vim.fn.expand("%:e")
                local icon, hl = MiniIcons.get("file", filename)
                vim.b[buf].lualine_icon = icon or ""
              end

              local filename = vim.fn.expand("%:t")
              if filename == "" then filename = "[No Name]" end
              return string.format(" %s %s", vim.b[buf].lualine_icon, filename)
            end,
          },
        },
        lualine_x = {
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
        lualine_y = { "progress" },
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
      extensions = { "quickfix", "oil", "lazy" },
    })
  end,
}
