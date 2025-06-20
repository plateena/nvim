return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "honza/vim-snippets",
    },
    config = function()
        local luasnip = require("luasnip")
        print("LuaSnip config loaded")
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()
        require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/luasnip" })
    end,
}
