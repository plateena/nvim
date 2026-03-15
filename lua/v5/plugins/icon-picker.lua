return {
  {
    "ziontee113/icon-picker.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    config = function()
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

      local function pick_icon_type()
        local types = { "emoji", "nerd_font", "alt_font", "html_colors", "symbols" }

        vim.ui.select(types, { prompt = "Select Icon Type" }, function(choice)
          if choice then
            vim.cmd("IconPickerNormal " .. choice)
          end
        end)
      end

      vim.keymap.set("n", "<Leader>ii", pick_icon_type)
      vim.keymap.set("i", "<C-;>", pick_icon_type)
      vim.keymap.set("n", "<Leader>iy", "<cmd>IconPickerYank<CR>")
    end,
  },
}
