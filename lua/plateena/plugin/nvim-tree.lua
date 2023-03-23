-- examples for your init.lua

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

-- OR setup with some options
require("nvim-tree").setup({
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
})

vim.keymap.set('n', '<leader>et', '<Cmd>NvimTreeToggle<Cr>', { desc = "Nvim tree toggle" })
vim.keymap.set('n', '<leader>ef', '<Cmd>NvimTreeFindFileToggle<Cr>', { desc = "Nvim tree find file toggle" })
