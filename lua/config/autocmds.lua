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

-- LSP stop/start commands with tab completion
vim.api.nvim_create_user_command("LspStop", function(opts)
  local name = opts.args
  local clients = vim.lsp.get_clients({ name = name })
  if #clients == 0 then
    vim.notify("No active LSP: " .. name, vim.log.levels.WARN)
    return
  end
  vim.lsp.stop_client(clients)
  vim.notify(name .. " stopped")
end, {
  nargs = 1,
  desc = "Stop an LSP by name",
  complete = function()
    local names = {}
    for _, c in ipairs(vim.lsp.get_clients()) do
      names[c.name] = true
    end
    return vim.tbl_keys(names)
  end,
})

vim.api.nvim_create_user_command("LspStart", function(opts)
  local name = opts.args
  -- Trigger FileType autocmd to re-attach the server
  vim.cmd("edit")
  vim.notify(name .. " starting...")
end, {
  nargs = 1,
  desc = "Start an LSP by name (re-triggers attach)",
  complete = function()
    return { "phpactor", "intelephense", "ts_ls", "pylsp", "bashls" }
  end,
})

-- Diff mode keymaps (only active in diff)
autocmd("OptionSet", {
  group = augroup("DiffKeymaps", { clear = true }),
  pattern = "diff",
  callback = function()
    if vim.opt.diff:get() then
      local buf = vim.api.nvim_get_current_buf()
      local opts = { buffer = buf, silent = true }
      vim.keymap.set("n", "gp", "<cmd>diffput<cr>", vim.tbl_extend("force", opts, { desc = "Diff put" }))
      vim.keymap.set("n", "gu", "<cmd>diffput<cr>", vim.tbl_extend("force", opts, { desc = "Diff put" }))
      vim.keymap.set("n", "go", "<cmd>diffget //3<cr>", vim.tbl_extend("force", opts, { desc = "Diff get (theirs)" }))
      vim.keymap.set("n", "gi", "<cmd>diffget //2<cr>", vim.tbl_extend("force", opts, { desc = "Diff get (ours)" }))
      vim.keymap.set("n", "<Tab>", "]c", vim.tbl_extend("force", opts, { desc = "Next hunk" }))
      vim.keymap.set("n", "<S-Tab>", "[c", vim.tbl_extend("force", opts, { desc = "Prev hunk" }))
    end
  end,
})
