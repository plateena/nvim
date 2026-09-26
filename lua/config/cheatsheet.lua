local M = {}

local GROUPS = {
  ["<leader>a"] = "AI",
  ["<leader>b"] = "Buffer",
  ["<leader>e"] = "Explorer",
  ["<leader>f"] = "Find",
  ["<leader>g"] = "Git",
  ["<leader>h"] = "Harpoon",
  ["<leader>i"] = "Icon",
  ["<leader>l"] = "LSP",
  ["<leader>m"] = "Format",
  ["<leader>o"] = "Options",
  ["<leader>q"] = "Quit",
  ["<leader>s"] = "Search/Replace",
  ["<leader>t"] = "Test",
  ["<leader>u"] = "UI",
  ["<leader>w"] = "Wiki/Write",
  ["<leader>x"] = "Diagnostics/Quickfix",
  ["<leader>y"] = "Yank",
}

local MODE_NAMES = {
  n = "Normal",
  i = "Insert",
  v = "Visual",
  x = "Visual",
  o = "Operator",
  c = "Command",
  t = "Terminal",
}

local function pretty_lhs(lhs)
  local leader = vim.g.mapleader == " " and " " or vim.g.mapleader
  lhs = lhs:gsub(vim.pesc(leader), "<leader>", 1)
  return lhs
end

local function group_for(lhs)
  for prefix, name in pairs(GROUPS) do
    if lhs:sub(1, #prefix) == prefix then
      return name
    end
  end
  if lhs:sub(1, 8) == "<leader>" then
    return "Leader (misc)"
  end
  return "General"
end

local function collect()
  local modes = { "n", "i", "v", "x", "o", "c", "t" }
  local seen = {}
  local grouped = {}

  for _, mode in ipairs(modes) do
    for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
      if km.desc and km.desc ~= "" then
        local lhs = pretty_lhs(km.lhs)
        local dedupe = lhs .. "|" .. km.desc
        if not seen[dedupe] then
          seen[dedupe] = true
          local group = group_for(lhs)
          grouped[group] = grouped[group] or {}
          table.insert(grouped[group], {
            lhs = lhs,
            desc = km.desc,
            mode = MODE_NAMES[mode] or mode,
          })
        end
      end
    end
  end

  return grouped
end

function M.generate()
  local grouped = collect()

  local group_names = vim.tbl_keys(grouped)
  table.sort(group_names)

  local lines = {
    "# Neovim Cheatsheet",
    "",
    "Generated from live keymaps. Run `:Cheatsheet` to refresh.",
    "",
    string.format("_Last generated: %s_", os.date("%Y-%m-%d %H:%M")),
    "",
  }

  for _, group in ipairs(group_names) do
    local maps = grouped[group]
    table.sort(maps, function(a, b)
      return a.lhs < b.lhs
    end)

    table.insert(lines, "## " .. group)
    table.insert(lines, "")
    table.insert(lines, "| Key | Mode | Action |")
    table.insert(lines, "|-----|------|--------|")

    for _, m in ipairs(maps) do
      local key = m.lhs:gsub("|", "\\|")
      local desc = m.desc:gsub("|", "\\|")
      table.insert(lines, string.format("| `%s` | %s | %s |", key, m.mode, desc))
    end

    table.insert(lines, "")
  end

  local path = vim.fs.joinpath(vim.fn.stdpath("config"), "CHEATSHEET.md")
  vim.fn.writefile(lines, path)
  vim.notify("Cheatsheet written to " .. path, vim.log.levels.INFO, { title = "Cheatsheet" })
  return path
end

vim.api.nvim_create_user_command("Cheatsheet", function()
  local path = M.generate()
  vim.cmd("edit " .. path)
end, { desc = "Generate and open the keymap cheatsheet" })

return M
