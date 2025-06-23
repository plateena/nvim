local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local expr = { noremap = true, silent = true, expr = true }

-- Map leader key to space
-- map("n", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Don't jump when using *
map("n", "*", "*<C-o>", opts)

-- Keep search matches in the middle of the window
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- Clear matches with Ctrl+l
-- map("n", "<leader><CR>", ":noh<Cr>", opts)

-- Reselect visual block after indent/outdent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Toggle ESC or <C-s> to go to normal mode in terminal
map("t", "<C-t>", "<C-\\><C-n>", opts)
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)

-- Resize windows with Shift+<arrow>
map("n", "<S-Up>", ":resize +2<CR>", opts)
map("n", "<S-Down>", ":resize -2<CR>", opts)
map("n", "<S-Left>", ":vertical resize -2<CR>", opts)
map("n", "<S-Right>", ":vertical resize +2<CR>", opts)

-- Move line up and down with J/K
map("x", "J", ":move '>+1<CR>gv-gv", opts)
map("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Don't yank when visual select paste
map("v", "p", '"_dP', opts)

-- Modify j and k when a line is wrapped. Jump to next VISUAL line
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr)

map('i', 'jk', '<Esc>', {})

map('n', 'YY', '"+p', {})
map('n', 'XX', '"+y', {})

vim.keymap.set('x', "<leader>p", "\"_dP", { desc = "Paste without yank the replace word" })
vim.keymap.set({ 'n', 'v' }, "<leader>y", "\"+y", { desc = "Yank to system clipboard" })
vim.keymap.set({ 'n', 'v' }, "<leader>Y", "\"+Y", { desc = "Yank with the new line" })
vim.keymap.set({ 'n', 'v' }, "<leader>d", "\"_d", { desc = "Delete to the void" })
vim.keymap.set({ 'n', 'v' }, "<leader>p", "\"+P", { desc = "Patse with the void" })
vim.keymap.set({ 'n', 'v' }, "<leader>p", "\"+p", { desc = "Paste without the void" })

vim.keymap.set('n', '<Leader>sv', ':source ~/.config/nvim/init.lua<Cr>', { desc = "Resource vim config file" })
vim.keymap.set('n', '<Leader>w', ':write<CR>', { desc = "Write file" })
vim.keymap.set('n', '<Leader>qq', ':q<CR>', { desc = "Quit nvim" })
vim.keymap.set('n', '<Leader>bd', ':bd<CR>', { desc = "Buffer delete" })
vim.keymap.set('n', '<Leader>bD', ':bufdo bd<CR>', { desc = "Delete all buffer" })

-- vim: ts=2 sw=2 et
