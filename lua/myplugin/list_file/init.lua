local M = {}

local devicons = require("nvim-web-devicons")

-- strip .md for display
local function strip_md(name)
  return name:gsub("%.md$", "")
end

-- icon by filetype (nvim-web-devicons)
local function get_icon(filename)
  local icon = devicons.get_icon(filename, nil, { default = true })
  return icon or ""
end

-- build ONLY content (NO markers here)
local function build_lines(dir)
  local items = vim.fn.readdir(dir)

  local folders = {}
  local files = {}

  for _, item in ipairs(items) do
    local full_path = dir .. "/" .. item
    local stat = vim.loop.fs_stat(full_path)

    if stat then
      if stat.type == "directory" then
        table.insert(folders, item)
      elseif stat.type == "file" then
        table.insert(files, item)
      end
    end
  end

  table.sort(folders, function(a, b)
    return a:lower() < b:lower()
  end)

  table.sort(files, function(a, b)
    return a:lower() < b:lower()
  end)

  local result = {}

  for _, item in ipairs(folders) do
    table.insert(result, string.format("-  **[%s](./%s/index.md)**", item, item))
  end

  for _, item in ipairs(files) do
    local name = strip_md(item)
    local icon = get_icon(item)

    table.insert(result, string.format("- %s [%s](./%s)", icon, name, item))
  end

  return result
end

-- find markers safely
local function find_markers(lines)
  local start_idx, end_idx

  for i, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    if trimmed == "<!-- FILE_LIST:START -->" then
      start_idx = i
    end

    if trimmed == "<!-- FILE_LIST:END -->" then
      end_idx = i
      break
    end
  end

  return start_idx, end_idx
end

function M.update_block()
  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local start_idx, end_idx = find_markers(lines)

  if not start_idx or not end_idx then
    return
  end

  local file = vim.fn.expand("%:p")
  local dir = vim.fn.fnamemodify(file, ":h")

  local content = build_lines(dir)

  local new_block = {}

  table.insert(new_block, "<!-- FILE_LIST:START -->")
  for _, line in ipairs(content) do
    table.insert(new_block, line)
  end
  table.insert(new_block, "<!-- FILE_LIST:END -->")

  vim.api.nvim_buf_set_lines(buf, start_idx - 1, end_idx, false, new_block)
end

function M.setup()
  vim.api.nvim_create_user_command("MdFileList", M.update_block, {})
end

return M
