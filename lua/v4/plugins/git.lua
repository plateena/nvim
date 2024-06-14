return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "<Leader>g", "", { desc = "Git" })
        vim.keymap.set("n", "<Leader>gs", "<Cmd>Git<Cr>", { desc = "Git" })
        vim.keymap.set("n", "<Leader>gl", "<Cmd>Git log<Cr>", { desc = "Git log" })
        vim.keymap.set("n", "<Leader>gv", "<Cmd>Gvdiffsplit<Cr>", { desc = "Git diff split" })
        vim.keymap.set("n", "<Leader>gh", "<Cmd>diffget //2<Cr>", { desc = "diffget //2" })
        vim.keymap.set("n", "<Leader>gl", "<Cmd>diffget //3<Cr>", { desc = "diffget //3" })
        vim.keymap.set("n", "<Leader>gu", "<Cmd>diffput //2<Cr>", { desc = "diffput //2" })
        vim.keymap.set("n", "<Leader>gi", "<Cmd>diffput //3<Cr>", { desc = "diffput //3" })
    end,
}
