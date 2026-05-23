local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-save on focus lost / buffer leave (only for real files)
autocmd({ "FocusLost", "BufLeave" }, {
  group = augroup("AutoSave", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.fn.expand("%") ~= "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! write")
      end)
    end
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  command = "tabdo wincmd =",
})

-- Close some filetypes with q
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "man", "qf", "checkhealth", "notify", "git" },
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

-- Auto-create parent directories on save
autocmd("BufWritePre", {
  group = augroup("AutoMkdir", { clear = true }),
  callback = function(args)
    local dir = vim.fn.fnamemodify(args.file, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Open URL under cursor or current file in browser
vim.api.nvim_create_user_command("Browse", function()
  local url = vim.fn.expand("<cWORD>")
  if not url:match("^https?://") then
    url = vim.fn.expand("%:p")
  end
  vim.fn.system({ "google-chrome", url })
end, { desc = "Open URL/file in Chrome" })
