vim.opt.cursorline = true

local function setColorscheme(color)
  color = color or "tokyonight"
  local ok, err = pcall(vim.cmd, "colorscheme " .. color)
  if not ok then vim.notify("colorscheme error: " .. err, vim.log.levels.ERROR) end
end
setColorscheme()

local function applyHighlights()
  local hl = vim.api.nvim_set_hl

  -- Cursor line
  hl(0, "CursorLine", { bg = "#2e2e2e" })
  hl(0, "CursorLineNr", { fg = "#e0af68", bold = true })

  -- Line numbers
  hl(0, "LineNrAbove", { fg = "#a0c8a0", bold = false })
  hl(0, "LineNr", { fg = "white", bold = false })
  hl(0, "LineNrBelow", { fg = "#c8a0a0", bold = false })

  -- Window separators (clean thin line)
  hl(0, "WinSeparator", { fg = "#3b4261", bg = "NONE" })

  -- Floating windows
  hl(0, "NormalFloat", { bg = "#1a1b26" })
  hl(0, "FloatBorder", { fg = "#565f89", bg = "NONE" })
  hl(0, "FloatTitle", { fg = "#7aa2f7", bg = "NONE", bold = true })

  -- Diagnostics (subtle backgrounds for virtual text)
  hl(0, "DiagnosticVirtualTextError", { fg = "#db4b4b", bg = "#2d202a" })
  hl(0, "DiagnosticVirtualTextWarn", { fg = "#e0af68", bg = "#2d2b20" })
  hl(0, "DiagnosticVirtualTextInfo", { fg = "#0db9d7", bg = "#1a2b32" })
  hl(0, "DiagnosticVirtualTextHint", { fg = "#1abc9c", bg = "#1a2b2b" })

  -- Inlay hints (dimmed)
  hl(0, "LspInlayHint", { fg = "#545c7e", bg = "NONE", italic = true })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = "#ff9e64", bold = true, underline = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserThemeHighlights", { clear = true }),
  callback = applyHighlights,
})

applyHighlights()
