local M = {}

function M.save_quickfix()
  local qflist = vim.fn.getqflist()
  local lines = {}
  
  for _, item in ipairs(qflist) do
    local bufname = vim.fn.bufname(item.bufnr)
    if bufname ~= "" then
      local line = string.format("%s:%d:%d: %s", bufname, item.lnum, item.col, item.text)
      table.insert(lines, line)
    end
  end
  
  local filename = vim.fn.input("Save quickfix to: ", "quickfix.txt")
  if filename ~= "" then
    vim.fn.writefile(lines, filename)
    print("Quickfix saved to " .. filename)
  end
end

function M.load_quickfix()
  local filename = vim.fn.input("Load quickfix from: ", "quickfix.txt")
  if filename ~= "" and vim.fn.filereadable(filename) == 1 then
    vim.cmd('cfile ' .. filename)
    vim.cmd('copen')
    print("Quickfix loaded from " .. filename)
  end
end

function M.setup()
  vim.api.nvim_create_user_command('SaveQF', M.save_quickfix, {})
  vim.api.nvim_create_user_command('LoadQF', M.load_quickfix, {})
  
  -- Optional keybindings
  vim.keymap.set('n', '<leader>qs', M.save_quickfix, { desc = 'Save quickfix list' })
  vim.keymap.set('n', '<leader>ql', M.load_quickfix, { desc = 'Load quickfix list' })
end

return M
