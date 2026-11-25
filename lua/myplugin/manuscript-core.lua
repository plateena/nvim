local M = {}

local defaults = {
  dir = "manuscript",
  extensions = { "md", "txt" },
  allow_extensionless = true,
  preset_tags = { "draft", "reviewed", "locked", "publish" },
}

local config = vim.deepcopy(defaults)

local function parse_tags(lines)
  for i = 1, math.min(5, #lines) do
    local tag_str = lines[i]:match("^<!%-%-%s*tags:%s*(.-)%s*%-%->")
    if tag_str then
      local tags = {}
      for tag in tag_str:gmatch("[^,]+") do
        local clean = vim.trim(tag):lower()
        if clean ~= "" and not vim.tbl_contains(tags, clean) then
          table.insert(tags, clean)
        end
      end
      return tags, i
    end
  end
  return {}, nil
end

local function get_chapter_meta(filepath, fallback)
  local file = io.open(filepath, "r")
  if not file then
    return fallback, {}
  end

  local lines = {}
  for _ = 1, 20 do
    local line = file:read("*l")
    if not line then
      break
    end
    table.insert(lines, line)
  end
  file:close()

  local tags = parse_tags(lines)
  local title = fallback

  for _, line in ipairs(lines) do
    local heading = line:match("^#%s+(.+)")
    if heading then
      title = heading
      break
    end
  end

  return title, tags
end

local function save_tags_to_file(filepath, new_tags)
  local bufnr = vim.fn.bufnr(filepath)
  local is_loaded = bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr)
  local lines = {}

  if is_loaded then
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  else
    local file = io.open(filepath, "r")
    if file then
      for line in file:lines() do
        table.insert(lines, line)
      end
      file:close()
    end
  end

  local _, existing_idx = parse_tags(lines)
  local tag_line = #new_tags > 0 and ("<!-- tags: " .. table.concat(new_tags, ", ") .. " -->") or nil

  if existing_idx then
    if tag_line then
      lines[existing_idx] = tag_line
    else
      table.remove(lines, existing_idx)
      if lines[existing_idx] == "" then
        table.remove(lines, existing_idx)
      end
    end
  elseif tag_line then
    table.insert(lines, 1, "")
    table.insert(lines, 1, tag_line)
  end

  if is_loaded then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("silent! write")
    end)
  else
    local file = io.open(filepath, "w")
    if file then
      file:write(table.concat(lines, "\n") .. "\n")
      file:close()
    end
  end
end

function M.toggle_tag_on_file(filepath, tag_name)
  local clean = vim.trim(tag_name):lower()
  if clean == "" then
    return {}
  end

  local _, current_tags = get_chapter_meta(filepath, "")
  local idx = nil
  for i, t in ipairs(current_tags) do
    if t == clean then
      idx = i
      break
    end
  end

  if idx then
    table.remove(current_tags, idx)
  else
    table.insert(current_tags, clean)
  end

  save_tags_to_file(filepath, current_tags)
  return current_tags
end

function M.tag_chapter(filepath, on_complete)
  filepath = filepath or vim.api.nvim_buf_get_name(0)
  if filepath == "" or vim.fn.filereadable(filepath) == 0 then
    vim.notify("Open or select a valid chapter file first.", vim.log.levels.WARN)
    return
  end

  local _, current_tags = get_chapter_meta(filepath, "")
  local choices = vim.deepcopy(config.preset_tags)

  for _, t in ipairs(current_tags) do
    if not vim.tbl_contains(choices, t) then
      table.insert(choices, t)
    end
  end
  table.insert(choices, "+ Add custom tag...")

  vim.ui.select(choices, {
    prompt = "Toggle Chapter Tag:",
    format_item = function(item)
      if item == "+ Add custom tag..." then
        return item
      end
      local active = vim.tbl_contains(current_tags, item)
      return string.format("[%s] %s", active and "x" or " ", item)
    end,
  }, function(choice)
    if not choice then
      return
    end

    if choice == "+ Add custom tag..." then
      vim.ui.input({ prompt = "New tag name: " }, function(input)
        if input and vim.trim(input) ~= "" then
          local updated = M.toggle_tag_on_file(filepath, input)
          vim.notify("Tags: " .. (#updated > 0 and table.concat(updated, ", ") or "none"))
          if on_complete then
            on_complete(updated)
          end
        end
      end)
    else
      local updated = M.toggle_tag_on_file(filepath, choice)
      vim.notify("Tags: " .. (#updated > 0 and table.concat(updated, ", ") or "none"))
      if on_complete then
        on_complete(updated)
      end
    end
  end)
end

local function resolve_manuscript_dir()
  local buf_dir = vim.fn.expand("%:p:h")
  local found = vim.fs.find(config.dir, {
    upward = true,
    path = buf_dir ~= "" and buf_dir or vim.fn.getcwd(),
    type = "directory",
  })

  if #found > 0 then
    return found[1]
  end

  local cwd_path = vim.fn.getcwd() .. "/" .. config.dir
  if vim.fn.isdirectory(cwd_path) == 1 then
    return cwd_path
  end

  return nil
end

local function is_valid_chapter(filename)
  if filename:sub(1, 1) == "." then
    return false
  end
  local ext = filename:match("%.([^.]+)$")
  if not ext then
    return config.allow_extensionless
  end
  return vim.tbl_contains(config.extensions, ext:lower())
end

local function get_chapters(target_dir)
  local chapters = {}
  for name, type in vim.fs.dir(target_dir) do
    if type == "file" and is_valid_chapter(name) then
      local full_path = target_dir .. "/" .. name
      local title, tags = get_chapter_meta(full_path, name)
      local badge = #tags > 0 and ("  [" .. table.concat(tags, ", ") .. "]") or ""
      local display = title ~= name and string.format("%s  (%s)%s", title, name, badge) or (name .. badge)

      table.insert(chapters, {
        filename = name,
        title = title,
        tags = tags,
        path = full_path,
        display = display,
      })
    end
  end

  table.sort(chapters, function(a, b)
    return a.filename < b.filename
  end)

  return chapters
end

local function matches_query(text, query)
  local haystack = text:lower()
  for word in query:lower():gmatch("%S+") do
    if not haystack:find(word, 1, true) then
      return false
    end
  end
  return true
end

function M.jump_to_chapter()
  local target_dir = resolve_manuscript_dir()
  if not target_dir then
    vim.notify("Could not find '" .. config.dir .. "' directory.", vim.log.levels.WARN)
    return
  end

  local chapters = get_chapters(target_dir)
  if #chapters == 0 then
    vim.notify("No chapter files found in " .. target_dir, vim.log.levels.INFO)
    return
  end

  local width = math.min(78, math.floor(vim.o.columns * 0.85))
  local list_height = math.min(14, math.max(5, #chapters))
  local row = math.floor((vim.o.lines - (list_height + 3)) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local prompt_buf = vim.api.nvim_create_buf(false, true)
  local list_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[list_buf].modifiable = false

  local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Chapters (<CR>: Open | <C-t>: Tag) ",
    title_pos = "center",
  })

  local list_win = vim.api.nvim_open_win(list_buf, false, {
    relative = "editor",
    width = width,
    height = list_height,
    row = row + 3,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[list_win].cursorline = true

  local filtered = {}
  local selected_idx = 1

  local function update_list(query)
    filtered = {}
    for _, ch in ipairs(chapters) do
      if query == "" or matches_query(ch.display, query) then
        table.insert(filtered, ch)
      end
    end

    local lines = {}
    for _, ch in ipairs(filtered) do
      table.insert(lines, " " .. ch.display)
    end

    if #lines == 0 then
      lines = { " (No matching chapters)" }
    end

    vim.bo[list_buf].modifiable = true
    vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, lines)
    vim.bo[list_buf].modifiable = false

    selected_idx = 1
    if vim.api.nvim_win_is_valid(list_win) then
      vim.api.nvim_win_set_cursor(list_win, { 1, 0 })
    end
  end

  local function close_picker()
    vim.cmd("stopinsert")
    if vim.api.nvim_win_is_valid(prompt_win) then
      vim.api.nvim_win_close(prompt_win, true)
    end
    if vim.api.nvim_win_is_valid(list_win) then
      vim.api.nvim_win_close(list_win, true)
    end
  end

  local function select_current()
    local choice = filtered[selected_idx]
    close_picker()
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice.path))
    end
  end

  local function tag_current()
    local choice = filtered[selected_idx]
    if not choice then
      return
    end
    close_picker()
    M.tag_chapter(choice.path, function()
      M.jump_to_chapter()
    end)
  end

  local function move_selection(delta)
    if #filtered == 0 then
      return
    end
    selected_idx = ((selected_idx - 1 + delta) % #filtered) + 1
    vim.api.nvim_win_set_cursor(list_win, { selected_idx, 0 })
  end

  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    buffer = prompt_buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)
      update_list(lines[1] or "")
    end,
  })

  local opts = { buffer = prompt_buf, silent = true }
  vim.keymap.set({ "i", "n" }, "<CR>", select_current, opts)
  vim.keymap.set({ "i", "n" }, "<C-t>", tag_current, opts)
  vim.keymap.set({ "i", "n" }, "<Esc>", close_picker, opts)
  vim.keymap.set({ "i", "n" }, "<C-c>", close_picker, opts)
  vim.keymap.set({ "i", "n" }, "<Down>", function() move_selection(1) end, opts)
  vim.keymap.set({ "i", "n" }, "<Up>", function() move_selection(-1) end, opts)
  vim.keymap.set("i", "<C-n>", function() move_selection(1) end, opts)
  vim.keymap.set("i", "<C-p>", function() move_selection(-1) end, opts)
  vim.keymap.set("i", "<C-j>", function() move_selection(1) end, opts)
  vim.keymap.set("i", "<C-k>", function() move_selection(-1) end, opts)

  update_list("")
  vim.cmd("startinsert")
end

local function setup_lock_protection()
  local group = vim.api.nvim_create_augroup("ManuscriptChapterLock", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = group,
    callback = function(args)
      local bufname = vim.api.nvim_buf_get_name(args.buf)
      local target_dir = resolve_manuscript_dir()
      if not target_dir or bufname == "" or not vim.startswith(bufname, target_dir) then
        return
      end

      local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 5, false)
      local tags = parse_tags(lines)
      local is_locked = vim.tbl_contains(tags, "locked")
      vim.bo[args.buf].modifiable = not is_locked
      if is_locked then
        vim.notify("Chapter is tagged [locked] (read-only).", vim.log.levels.INFO)
      end
    end,
  })
end

local is_setup = false
function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})
  if is_setup then
    return
  end
  is_setup = true

  setup_lock_protection()

  vim.api.nvim_create_user_command("ChapterJump", function()
    M.jump_to_chapter()
  end, { desc = "Search, tag, and jump to a chapter" })

  vim.api.nvim_create_user_command("ChapterTag", function(cmd_opts)
    if cmd_opts.args ~= "" then
      local updated = M.toggle_tag_on_file(vim.api.nvim_buf_get_name(0), cmd_opts.args)
      vim.notify("Tags: " .. (#updated > 0 and table.concat(updated, ", ") or "none"))
    else
      M.tag_chapter()
    end
  end, {
    nargs = "?",
    complete = function()
      return config.preset_tags
    end,
    desc = "Toggle a tag on the current chapter",
  })
end

return M
