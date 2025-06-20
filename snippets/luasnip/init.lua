-- ~/.config/nvim/lua/snippets/init.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

ls.add_snippets("all", {
  s("demo", t("This is a test snippet")),
})
