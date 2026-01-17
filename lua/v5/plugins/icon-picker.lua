return {
  {
    "ziontee113/icon-picker.nvim",
    dependencies = { "stevearc/dressing.nvim" },
    config = function()
      require("dressing").setup({
        input = { enabled = false },
        select = {
          backend = { "telescope", "fzf", "builtin" },
          telescope = { layout_config = { width = 0.4 } },
        },
      })

      local icon_picker = require("icon-picker")
      icon_picker.setup({
        disable_legacy_commands = true,
        preset = "emoji",
        picker_config = {
          prompt = "Pick Icon > ",
          format_item = function(item)
            return item.icon .. "  " .. item.name
          end,
          initial_mode = "insert",
        },
      })

      local function pick_icon_type()
        local types = { "emoji", "nerd_font", "alt_font", "html_colors", "symbols" }
        vim.ui.select(types, { prompt = "Select Icon Type" }, function(choice)
          if choice then
            vim.cmd("IconPickerNormal " .. choice)
          end
        end)
      end

      -- keymaps
      vim.keymap.set("n", "<Leader>ii", pick_icon_type, { desc = "Pick icon (normal)" })
      vim.keymap.set("i", "<C-;>", pick_icon_type, { desc = "Pick icon (insert mode)" })
      vim.keymap.set("n", "<Leader>iy", "<cmd>IconPickerYank<CR>", { desc = "Pick icon to yank" })
    end,
  },
}
