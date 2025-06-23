-- Enable cursorline
vim.opt.cursorline = true

-- (Optional) If you want to load a colorscheme manually, uncomment below:
local function setColorscheme(color)
  color = color or "tokyonight"
  local ok, err = pcall(vim.cmd, "colorscheme " .. color)
  if not ok then vim.notify("colorscheme error: " .. err, vim.log.levels.ERROR) end
end
setColorscheme()

-- Apply all custom highlight groups
local function applyHighlights()
  local hl = vim.api.nvim_set_hl

  -- Cursor line background
  hl(0, "CursorLine", { bg = "#2e2e2e" })

  -- Line number coloring
  hl(0, "LineNrAbove",  { fg = "#a0c8a0", bold = false })
  hl(0, "LineNr",       { fg = "white",   bold = false })
  hl(0, "LineNrBelow",  { fg = "#c8a0a0", bold = false })
end

-- Ensure highlights apply after any colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserThemeHighlights", { clear = true }),
  callback = applyHighlights,
})

-- Initial application
applyHighlights()
