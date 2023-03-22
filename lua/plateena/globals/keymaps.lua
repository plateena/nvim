map = vim.api.nvim_set_keymap
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

-- Doble ESC or <C-s> to go to normal mode in terminal
map("t", "<C-s>", "<C-\\><C-n>", opts)
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)

-- Resize windows with Shift+<arrow>
map("n", "<S-Up>", ":resize +2<CR>", opts)
map("n", "<S-Down>", ":resize -2<CR>", opts)
map("n", "<S-Left>", ":vertical resize -2<CR>", opts)
map("n", "<S-Right>", ":vertical resize +2<CR>", opts)

-- Move line up and down with J/K
map("x", "J", ":move '>+1<CR>gv-gv", opts)
-- map("x", "K", ":move '<-2<CR>gv-gv")

-- Don't yank when visual select paste
map("v", "p", '"_dP', opts)

-- Modify j and k when a line is wrapped. Jump to next VISUAL line
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr)

map('n', '<Leader>w', ':write<CR>',{})
map('n', '<Leader>bd', ':bd<CR>',{})
map('n', '<Leader>bda', ':bufdo bd<CR>',{})
map('i', 'jk', '<Esc>',{})
map('n', '<Leader>sv', ':source ~/.config/nvim/init.lua<Cr>',{})

map('n', 'YY', '"+p',{})
map('n', 'XX', '"+y',{})

-- vim: ts=2 sw=2 et
