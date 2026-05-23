local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Don't jump when using *
map("n", "*", "*<C-o>", { desc = "Search word without jumping" })

-- Keep search matches in the middle
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Clear search highlight
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "Clear search highlight" })

-- Reselect visual block after indent/outdent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Terminal escape
map("t", "<C-t>", "<C-\\><C-n>")
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- Resize windows with Shift+<arrow>
map("n", "<S-Up>", "<cmd>resize +2<cr>")
map("n", "<S-Down>", "<cmd>resize -2<cr>")
map("n", "<S-Left>", "<cmd>vertical resize -2<cr>")
map("n", "<S-Right>", "<cmd>vertical resize +2<cr>")

-- Move lines in visual mode
map("x", "J", ":move '>+1<CR>gv-gv", { silent = true })
map("x", "K", ":move '<-2<CR>gv-gv", { silent = true })

-- Don't yank on visual paste
map("v", "p", '"_dP')

-- Wrapped line navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Quick escape
map("i", "jk", "<Esc>")

-- Command-line navigation
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-h>", "<Left>")
map("c", "<C-l>", "<Right>")
map("c", "<C-j>", "<Down>")
map("c", "<C-k>", "<Up>")

-- Clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from clipboard" })
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to void" })
map("x", "<leader>p", '"_dP', { desc = "Paste over without yank" })

-- File/buffer
map("n", "<leader>yf", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Yank full path" })
map("n", "<leader>yr", function() vim.fn.setreg("+", vim.fn.expand("%:.")) end, { desc = "Yank relative path" })
map("n", "<leader>yn", function() vim.fn.setreg("+", vim.fn.expand("%:t")) end, { desc = "Yank filename" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bufdo bd<cr>", { desc = "Delete all buffers" })

-- Buffer navigation
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Quickfix navigation
map("n", "[q", "<cmd>cprev<cr>zz", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>zz", { desc = "Next quickfix" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>xQ", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Source config
map("n", "<leader>sv", "<cmd>source ~/.config/nvim/init.lua<cr>", { desc = "Source nvim config" })

-- Tmux-aware window navigation
local function tmux_or_win(direction)
  local current_win = vim.fn.winnr()
  vim.cmd("wincmd " .. direction)
  if current_win == vim.fn.winnr() and vim.env.TMUX then
    local pane_cmd = { h = "L", j = "D", k = "U", l = "R" }
    if pane_cmd[direction] then
      vim.fn.system("tmux select-pane -" .. pane_cmd[direction])
    end
  end
end

map("n", "<C-h>", function() tmux_or_win("h") end, { desc = "Move left (vim/tmux)" })
map("n", "<C-j>", function() tmux_or_win("j") end, { desc = "Move down (vim/tmux)" })
map("n", "<C-k>", function() tmux_or_win("k") end, { desc = "Move up (vim/tmux)" })
map("n", "<C-l>", function() tmux_or_win("l") end, { desc = "Move right (vim/tmux)" })

-- vim: ts=2 sw=2 et
