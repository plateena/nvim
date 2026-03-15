return {
  {
    "ziontee113/icon-picker.nvim",
    dependencies = {
      {
        "stevearc/dressing.nvim",
        -- force early loading so vim.ui.input is hooked
        lazy = false,
        priority = 1000, -- load early
        config = function()
          require("dressing").setup({
            input = {
              enabled = true, -- enable vim.ui.input override
            },
            select = {
              enabled = true,
              backend = { "telescope", "fzf", "builtin" },
              telescope = { layout_config = { width = 0.4 } },
            },
          })
        end,
      },
    },
    config = function()
      -- Wrap vim.ui.input/select so dressing always loads
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "stevearc/dressing.nvim" } })
        return vim.ui.input(...)
      end

      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "stevearc/dressing.nvim" } })
        return vim.ui.select(...)
      end

      -- Setup the icon picker
      require("icon-picker").setup({
        disable_legacy_commands = true,
        picker_config = {
          prompt = "Pick Icon > ",
          format_item = function(item)
            return item.icon .. "  " .. item.name
          end,
          initial_mode = "insert",
        },
      })

      -- A helper to pick icon types
      local function pick_icon_type()
        local types = { "emoji", "nerd_font", "alt_font", "html_colors", "symbols" }
        vim.ui.select(types, { prompt = "Select Icon Type" }, function(choice)
          if choice then
            vim.cmd("IconPickerNormal " .. choice)
          end
        end)
      end

      -- Keymaps
      vim.keymap.set("n", "<Leader>ii", pick_icon_type, { desc = "Pick icon (normal)" })
      vim.keymap.set("i", "<C-;>", pick_icon_type, { desc = "Pick icon (insert mode)" })
      vim.keymap.set("n", "<Leader>iy", "<cmd>IconPickerYank<CR>", { desc = "Pick icon to yank" })
    end,
  },
}
