local M = {}

M.tips = {
  { key = "s", desc = "Flash jump anywhere in 2-3 keystrokes" },
  { key = "S", desc = "Flash treesitter select" },
  { key = "ga", desc = "Align selection on a character (mini.align)" },
  { key = "gA", desc = "Align with live preview" },
  { key = "<leader>ha", desc = "Add file to Harpoon (<C-e> menu, Alt+1..5 jump)" },
  { key = "<leader>fr", desc = "Resume last picker" },
  { key = "<leader>fs", desc = "Grep word under cursor" },
  { key = "<leader>fW", desc = "Grep the current word globally" },
  { key = "<leader>tn", desc = "Run nearest test (neotest)" },
  { key = "<leader>tt", desc = "Toggle test summary panel" },
  { key = "<leader>la", desc = "Code action with live diff preview" },
  { key = "<leader>ls", desc = "Document symbols picker" },
  { key = "<leader>lS", desc = "Workspace symbols picker" },
  { key = "-", desc = "Oil: edit parent directory as a buffer" },
  { key = "<leader>ee", desc = "Snacks file explorer" },
  { key = "<leader>gg", desc = "Lazygit" },
  { key = "<leader>gd", desc = "Diffview open" },
  { key = "<leader>gh", desc = "Git file history" },
  { key = "<leader>ww", desc = "Wiki index" },
  { key = "<leader>ai", desc = "Toggle AI chat (CodeCompanion)" },
  { key = "<leader>fp", desc = "Switch project" },
  { key = "<leader>v", desc = "Treesitter incremental selection" },
  { key = "]m / [m", desc = "Jump next/prev function" },
  { key = "af / if", desc = "Select outer/inner function (textobject)" },
  { key = "<leader>fk", desc = "Search all keymaps (when you forget one)" },
}

function M.random()
  return M.tips[math.random(#M.tips)]
end

function M.formatted()
  local tip = M.random()
  return string.format("  %s  %s", tip.key, tip.desc)
end

function M.sample(n)
  local pool = {}
  for i, tip in ipairs(M.tips) do
    pool[i] = tip
  end

  for i = #pool, 2, -1 do
    local j = math.random(i)
    pool[i], pool[j] = pool[j], pool[i]
  end

  n = math.min(n or 8, #pool)
  local lines = {}
  for i = 1, n do
    local key = string.format("%-12s", pool[i].key)
    table.insert(lines, { string.format("  %s  %s", key, pool[i].desc), hl = "special" })
    table.insert(lines, { "\n" })
  end
  return lines
end

return M
