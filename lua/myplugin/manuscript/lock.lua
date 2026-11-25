local M = {}

function M.setup(config, chapters)
  local group = vim.api.nvim_create_augroup("MypluginChapterLock", { clear = true })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = group,
    callback = function(args)
      local filepath = vim.api.nvim_buf_get_name(args.buf)
      if filepath == "" then
        return
      end

      local directory = chapters.resolve_dir(config, filepath)
      if not directory or not chapters.is_inside(filepath, directory) then
        return
      end

      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 5, false)
      local tags = require("myplugin.manuscript.tags").parse(lines)
      local locked = vim.tbl_contains(tags, "locked")

      vim.bo[args.buf].modifiable = not locked

      if locked and args.event == "BufReadPost" then
        vim.notify("Chapter is tagged [locked] (read-only).", vim.log.levels.INFO)
      end
    end,
  })
end

return M
