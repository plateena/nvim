-- copilot add documentation to your code
vim.g.copilot_filetypes = { ["*"] = false, typescript = true, php = true, lua = true }

vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

vim.keymap.set('i', '<M-l>', '<Plug>(copilot-suggest)')
vim.keymap.set('i', '<M-]>', '<Plug>(copilot-dismiss)')
vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)')
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-accept-line)')
vim.keymap.set('i', '<C-p>', '<Plug>(copilot-next-suggestion)')
vim.keymap.set('i', '<C-n>', '<Plug>(copilot-prev-suggestion)')
