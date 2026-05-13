return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip" },
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "default",
      ["<C-k>"] = { "show" },
      ["<C-e>"] = { "hide" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up" },
      ["<C-f>"] = { "scroll_documentation_down" },
    },
    snippets = { preset = "luasnip" },
    sources = {
      default = { "lsp", "snippets", "buffer", "path" },
      cmdline = {},
    },
    completion = {
      ghost_text = { enabled = true },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = {
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 }, { "source_name" } },
        },
      },
    },
    signature = { enabled = true },
  },
}
