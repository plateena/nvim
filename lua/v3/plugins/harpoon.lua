return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        harpoon.setup()

        vim.keymap.set("n", "<C-h>a", function()
            harpoon:list():add()
        end, { desc = "Add file to harpoon" })
        vim.keymap.set("n", "<C-h>e", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Toggle harpoon list" })

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<C-h>p", function()
            harpoon:list():prev()
        end, { desc = "Harpoon previous file" })
        vim.keymap.set("n", "<C-h>n", function()
            harpoon:list():next()
        end, { desc = "Harpoon next file" })
    end,
}
