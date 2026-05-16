return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = { "rafamadriz/friendly-snippets", "honza/vim-snippets" },
  event = { "InsertEnter", "CmdlineEnter" },
  config = function()
    local luasnip = require("luasnip")
    local types = require("luasnip.util.types")

    require("luasnip.loaders.from_vscode").lazy_load({
      exclude = { "gruvbox" },
    })
    require("luasnip.loaders.from_snipmate").lazy_load()

    local custom_path = vim.fn.stdpath("config") .. "/snippets/luasnip"
    if vim.fn.isdirectory(custom_path) == 1 then
      require("luasnip.loaders.from_lua").load({ paths = { custom_path } })
    end

    luasnip.config.setup({
      enable_autosnippets = true,
      store_selection_keys = "<C-s>",
      update_events = { "TextChangedI", "TextChangedP" },
      delete_check_events = { "TextChanged", "InsertLeave" },
      ext_opts = {
        [types.choiceNode] = { active = { virt_text = { { "●", "DiagnosticWarn" } } } },
        [types.insertNode] = { active = { virt_text = { { "●", "DiagnosticInfo" } } } },
      },
    })

    vim.keymap.set({ "i", "s" }, "<C-p>", function()
      if luasnip.choice_active() then luasnip.change_choice(1) end
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-n>", function()
      if luasnip.choice_active() then luasnip.change_choice(-1) end
    end, { silent = true })
  end,
}
