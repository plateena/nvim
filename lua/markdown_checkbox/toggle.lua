local M = {}

M.run = function(start_line, end_line)
  for line_num = start_line, end_line do
    local line = vim.fn.getline(line_num)

    -- Match lines that have '[ ]' (unchecked) checkbox
    if line:match('^%s*[%-%+=~*]*%s*%[%s*%]') then
      -- Capture everything up to the checkbox including leading spaces and symbols
      local before_checkbox, rest_of_line = line:match('^(%s*[%-%+=~*]*%s*)%[%s*%](.*)')
      vim.fn.setline(line_num, before_checkbox .. "[x]" .. rest_of_line)
    -- Match lines that have '[x]' or '[X]' (checked) checkbox
    elseif line:match('^%s*[%-%+=~*]*%s*%[[xX]%](.*)') then
      -- Capture everything up to the checkbox including leading spaces and symbols
      local before_checkbox, rest_of_line = line:match('^(%s*[%-%+=~*]*%s*)%[[xX]%](.*)')
      vim.fn.setline(line_num, before_checkbox .. "[ ]" .. rest_of_line)
    end
  end
end

return M
