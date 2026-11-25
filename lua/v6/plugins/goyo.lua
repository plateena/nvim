return {
  "junegunn/goyo.vim",
  cmd = "Goyo",
  config = function()
    vim.g.goyo_width = 120
    vim.g.goyo_height = "85%"
    vim.g.goyo_linenr = 1

    local group = vim.api.nvim_create_augroup("GoyoLualine", {
      clear = true,
    })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "GoyoEnter",
      callback = function()
        -- Override Goyo's laststatus=0.
        vim.o.laststatus = 3

        local ok, lualine = pcall(require, "lualine")
        if ok then
          lualine.refresh()
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "GoyoLeave",
      callback = function()
        local ok, lualine = pcall(require, "lualine")
        if ok then
          lualine.refresh()
        end
      end,
    })
  end,
}
