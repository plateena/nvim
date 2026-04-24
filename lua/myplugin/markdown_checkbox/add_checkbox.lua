local M = {}

M.run = function(start_line, end_line)
    for line_num = start_line, end_line do
        local line = vim.fn.getline(line_num)
        if line:match('^%s*[%-%+=~*0-9]*%.?%s*') then
            -- Match leading spaces and the first symbol (hyphen, plus, etc.)
            local leading_spaces, rest_of_line = line:match('^(%s*[%-%+=~*0-9]*%.?%s*)(.*)')
            vim.fn.setline(line_num, leading_spaces .. "[ ] " .. rest_of_line)
        else
            -- Otherwise, prepend '[ ]' to the entire line
            vim.fn.setline(line_num, "[ ] " .. line)
        end
    end
end

return M
