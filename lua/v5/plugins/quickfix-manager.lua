return {
  {
    "folke/lazy.nvim", -- Use an existing plugin as base
    name = "quickfix-manager",
    config = function()
      local function save_quickfix()
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

      local function load_quickfix()
        local filename = vim.fn.input("Load quickfix from: ", "quickfix.txt")
        if filename ~= "" and vim.fn.filereadable(filename) == 1 then
          vim.cmd('cfile ' .. filename)
          vim.cmd('copen')
          print("Quickfix loaded from " .. filename)
        end
      end

      vim.api.nvim_create_user_command('SaveQF', save_quickfix, {})
      vim.api.nvim_create_user_command('LoadQF', load_quickfix, {})
      
      vim.keymap.set('n', '<leader>qs', save_quickfix, { desc = 'Save quickfix list' })
      vim.keymap.set('n', '<leader>ql', load_quickfix, { desc = 'Load quickfix list' })
    end,
  }
}
