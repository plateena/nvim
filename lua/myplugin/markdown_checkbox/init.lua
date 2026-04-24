-- ~/.config/nvim/lua/myplugin/markdown_checkbox/init.lua
local M = {}

M.setup = function()
    -- Set up autocommands and keymaps for Markdown files
    vim.api.nvim_create_augroup("MarkdownCheckbox", { clear = true })

    -- Create autocommand to run the AddCheckBox function for markdown files only
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown", -- Only for markdown files
        group = "MarkdownCheckbox",
        callback = function()
            -- Key mapping for AddCheckBox and ToggleCheckBox
            vim.api.nvim_set_keymap('n', '<leader>c',
                ':lua require("markdown_checkbox.add_checkbox").run(vim.fn.line("."), vim.fn.line("."))<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('v', '<leader>c',
                ':lua require("markdown_checkbox.add_checkbox").run(vim.fn.getpos("\'<")[2], vim.fn.getpos("\'>")[2])<CR>',
                { noremap = true, silent = true })

            vim.api.nvim_set_keymap('n', '<leader>t',
                ':lua require("markdown_checkbox.toggle").run(vim.fn.line("."), vim.fn.line("."))<CR>',
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('v', '<leader>t',
                ':lua require("markdown_checkbox.toggle").run(vim.fn.getpos("\'<")[2], vim.fn.getpos("\'>")[2])<CR>',
                { noremap = true, silent = true })
        end,
    })
end

return M
