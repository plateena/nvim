local M = {}

local function normalize_path(filepath)
  return vim.fs.normalize(vim.fn.fnamemodify(filepath, ":p"))
end

local function read_lines(filepath, limit)
  local lines = vim.fn.readfile(filepath, "", limit or 0)
  return lines or {}
end

local function normalize_tags(tags)
  local normalized = {}
  local seen = {}

  for _, tag in ipairs(tags or {}) do
    local clean = vim.trim(tag):lower()

    if clean ~= "" and not seen[clean] then
      seen[clean] = true
      table.insert(normalized, clean)
    end
  end

  return normalized
end

local function get_buffer(filepath)
  filepath = normalize_path(filepath)

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)

      if name ~= "" and normalize_path(name) == filepath then
        return bufnr
      end
    end
  end

  return nil
end

local function has_tag(tags, tag_name)
  return vim.tbl_contains(tags, tag_name)
end

function M.parse(lines)
  for i = 1, math.min(5, #lines) do
    local tag_string = lines[i]:match("^<!%-%-%s*tags:%s*(.-)%s*%-%->")

    if tag_string then
      return normalize_tags(vim.split(tag_string, ",", {
        plain = true,
        trimempty = true,
      })), i
    end
  end

  return {}, nil
end

function M.get(filepath)
  if not filepath or filepath == "" then
    return {}
  end

  return M.parse(read_lines(filepath, 20))
end

-- Return all unique tags used by the supplied chapters.
function M.list(chapters, preset_tags)
  local tags = {}
  local seen = {}

  local function add(tag)
    local clean = vim.trim(tag):lower()

    if clean ~= "" and not seen[clean] then
      seen[clean] = true
      table.insert(tags, clean)
    end
  end

  for _, tag in ipairs(preset_tags or {}) do
    add(tag)
  end

  for _, chapter in ipairs(chapters or {}) do
    for _, tag in ipairs(M.get(chapter.path)) do
      add(tag)
    end
  end

  table.sort(tags)

  return tags
end

-- Return chapters containing the specified tag.
function M.find(chapters, tag_name)
  local clean = vim.trim(tag_name or ""):lower()

  if clean == "" then
    return {}
  end

  local matching = {}

  for _, chapter in ipairs(chapters or {}) do
    if has_tag(M.get(chapter.path), clean) then
      table.insert(matching, chapter)
    end
  end

  return matching
end

function M.save(filepath, new_tags)
  if not filepath or filepath == "" then
    vim.notify("myplugin: no chapter file specified.", vim.log.levels.WARN)
    return false
  end

  filepath = normalize_path(filepath)

  if vim.fn.filereadable(filepath) == 0 then
    vim.notify("myplugin: chapter file not found: " .. filepath, vim.log.levels.ERROR)
    return false
  end

  local bufnr = get_buffer(filepath)

  local lines

  if bufnr then
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  else
    lines = read_lines(filepath)
  end

  local tags = normalize_tags(new_tags)
  local _, existing_index = M.parse(lines)

  local tag_line = #tags > 0 and ("<!-- tags: " .. table.concat(tags, ", ") .. " -->") or nil

  if existing_index then
    if tag_line then
      lines[existing_index] = tag_line
    else
      table.remove(lines, existing_index)
    end
  elseif tag_line then
    table.insert(lines, 1, "")
    table.insert(lines, 1, tag_line)
  end

  if bufnr then
    local original_modifiable = vim.bo[bufnr].modifiable

    local ok, err = pcall(function()
      vim.bo[bufnr].modifiable = true

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent write")
      end)
    end)

    if not ok then
      vim.bo[bufnr].modifiable = original_modifiable

      vim.notify("myplugin: could not save tags: " .. tostring(err), vim.log.levels.ERROR)

      return false
    end

    -- Locked chapters remain non-modifiable.
    vim.bo[bufnr].modifiable = not has_tag(tags, "locked")
  else
    local result = vim.fn.writefile(lines, filepath)

    if result ~= 0 then
      vim.notify("myplugin: could not write " .. filepath, vim.log.levels.ERROR)

      return false
    end
  end

  return true
end

function M.toggle(filepath, tag_name)
  if not tag_name or vim.trim(tag_name) == "" then
    return nil
  end

  local clean = vim.trim(tag_name):lower()
  local tags = M.get(filepath)
  local index

  for i, tag in ipairs(tags) do
    if tag == clean then
      index = i
      break
    end
  end

  if index then
    table.remove(tags, index)
  else
    table.insert(tags, clean)
  end

  if not M.save(filepath, tags) then
    return nil
  end

  return tags
end

return M
