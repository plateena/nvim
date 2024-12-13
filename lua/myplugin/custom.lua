-- Define the ToggleCheckBox function globally
function ToggleCheckBox(start_line, end_line)
    -- Loop through each selected line
    for line_num = start_line, end_line do
        local line = vim.fn.getline(line_num)

        -- Match lines that have '[ ]' (unchecked) checkbox
        if line:match('^%s*[%-%+=~*]*%s*%[%s*%]') then
            -- Capture everything up to the checkbox including leading spaces and symbols
            local before_checkbox, rest_of_line = line:match('^(%s*[%-%+=~*]*%s*)%[%s*%](.*)')
            -- Set the checkbox to '[x]' and preserve the rest of the line
            vim.fn.setline(line_num, before_checkbox .. "[x]" .. rest_of_line)

            -- Match lines that have '[x]' or '[X]' (checked) checkbox
        elseif line:match('^(%s*[%-%+=~*]*%s*)(%[[xX]%])(.*)') then
            -- Capture everything up to the checkbox including leading spaces and symbols
            local before_checkbox, rest_of_line = line:match('^(%s*[%-%+=~*]*%s*)%[[xX]%](.*)')
            -- Set the checkbox to '[ ]' and preserve the rest of the line
            vim.fn.setline(line_num, before_checkbox .. "[ ]" .. rest_of_line)
        end
    end
end

-- Define the AddCheckBox function globally
function AddCheckBox(start_line, end_line)
    -- Loop through each selected line
    for line_num = start_line, end_line do
        local line = vim.fn.getline(line_num)
        if line:match('^%s*[%-%+=~*]%s*') then
            -- Match leading spaces and the first hyphen
            local leading_spaces, rest_of_line = line:match('^(%s*%-)(.*)')
            -- Insert '[ ]' right after the hyphen
            vim.fn.setline(line_num, leading_spaces .. " [ ]" .. rest_of_line)
        else
            -- Otherwise, prepend '[ ]' to the entire line
            vim.fn.setline(line_num, "[ ] " .. line)
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
        vim.api.nvim_set_keymap('n', '<leader>c', ':lua AddCheckBox(vim.fn.line("."), vim.fn.line("."))<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('v', '<leader>c',
            ':lua AddCheckBox(vim.fn.getpos("\'<")[2], vim.fn.getpos("\'>")[2])<CR>', { noremap = true, silent = true })

        -- Map a keybinding only for markdown files, e.g., <leader>t for ToggleCheckBox
        vim.api.nvim_set_keymap('n', '<leader>t', ':lua ToggleCheckBox(vim.fn.line("."), vim.fn.line("."))<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('v', '<leader>t',
            ':lua ToggleCheckBox(vim.fn.getpos("\'<")[2], vim.fn.getpos("\'>")[2])<CR>',
            { noremap = true, silent = true })
    end,
})
