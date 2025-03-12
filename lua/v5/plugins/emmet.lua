return {
    "olrtg/nvim-emmet",
    config = function()
        local emmet = require('nvim-emmet')
        vim.keymap.set({ "n", "v", "i" }, "<C-y>,", emmet.wrap_with_abbreviation)
    end,
}
