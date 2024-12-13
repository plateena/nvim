local function RunAddCheckbox(line_num, line)
    if line:match('^%s*%-') then
        -- Match leading spaces and the first hyphen
        local leading_spaces, rest_of_line = line:match('^(%s*%-)(.*)')
        -- Insert '[ ]' right after the hyphen
        vim.fn.setline(line_num, leading_spaces .. " [ ]" .. rest_of_line)
    else
        -- Otherwise, prepend '[ ]' to the entire line
        vim.fn.setline(line_num, "[ ] " .. line)
    end
end

-- Define the AddCheckBox function globally
function AddCheckBox(start_line, end_line)
    print("Start line: " .. start_line)
    print("End line: " .. end_line)

    if start_line == end_line then
        -- If the start and end lines are the same, insert a checkbox at the current line
        local line = vim.fn.getline(start_line)
        RunAddCheckbox(start_line, line)
    else
        -- Loop through each selected line
        for line_num = start_line, end_line do
            local line = vim.fn.getline(line_num)
            RunAddCheckbox(line_num, line)
        end
    end
end

-- Set up an autocommand group for Markdown files
vim.api.nvim_create_augroup("MarkdownCheckbox", { clear = true })

-- Create an autocommand to run the AddCheckBox function for Markdown files only
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown", -- Only for markdown files
    group = "MarkdownCheckbox",
    callback = function()
        -- Map a keybinding only for markdown files, e.g., <leader>c
        vim.api.nvim_set_keymap('n', '<leader>c', ':lua AddCheckBox(vim.fn.line("."), vim.fn.line("."))<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('v', '<leader>c', ':lua AddCheckBox(vim.fn.getpos("\'<")[2], vim.fn.getpos("\'>")[2])<CR>', { noremap = true, silent = true })
    end,
})
