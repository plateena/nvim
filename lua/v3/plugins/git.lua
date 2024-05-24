return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set('n', '<Leader>gh', '<Cmd>diffget //2<Cr>', { desc = "diffget //2" })
        vim.keymap.set('n', '<Leader>gl', '<Cmd>diffget //3<Cr>', { desc = "diffget //3" })
        vim.keymap.set('n', '<Leader>gu', '<Cmd>diffput //2<Cr>', { desc = "diffput //2" })
        vim.keymap.set('n', '<Leader>gp', '<Cmd>diffput //3<Cr>', { desc = "diffput //3" })
    end
}
