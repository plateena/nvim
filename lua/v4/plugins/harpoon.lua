return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim", lazy = true },
    config = function()
        local harpoon = require("harpoon")
        local ui = require('harpoon.ui')

        local idx = vim.fn.line('.')
        harpoon:setup()

        vim.keymap.set("n", "<leader>h", "", {
            desc = "Harpoon2"
        })
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, {
            desc = "Add buffer to harpoon"
        })
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        vim.keymap.set("n", "<a-1>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<a-2>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<a-3>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<a-4>", function() harpoon:list():select(4) end)
        vim.keymap.set("n", "<a-5>", function() harpoon:list():select(5) end)
        vim.keymap.set("n", "<C-h>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<C-l>", function() harpoon:list():next() end)
    end,
}
