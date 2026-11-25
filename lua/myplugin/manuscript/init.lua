local M = {}

local config
local is_setup = false

local function notify_tags(tags)
  vim.notify("Tags: " .. (#tags > 0 and table.concat(tags, ", ") or "none"))
end

local function get_chapters()
  local chapters = require("myplugin.manuscript.chapters")
  local directories = chapters.resolve_dirs(config)

  if #directories == 0 then
    vim.notify("myplugin: could not find any configured manuscript directories.", vim.log.levels.WARN)
    return {}
  end

  local chapter_list = chapters.list(directories, config)

  if #chapter_list == 0 then
    vim.notify("No chapter files found in: " .. table.concat(directories, ", "), vim.log.levels.INFO)
  end

  return chapter_list
end

function M.toggle_tag_on_file(filepath, tag_name)
  if not filepath or filepath == "" then
    vim.notify("myplugin: no chapter file specified.", vim.log.levels.WARN)
    return nil
  end

  local tags = require("myplugin.manuscript.tags").toggle(filepath, tag_name)

  if tags then
    notify_tags(tags)
  end

  return tags
end

function M.tag_chapter(filepath, on_complete)
  filepath = filepath or vim.api.nvim_buf_get_name(0)

  if filepath == "" or vim.fn.filereadable(filepath) == 0 then
    vim.notify("Open or select a valid chapter file first.", vim.log.levels.WARN)
    return
  end

  local tag_module = require("myplugin.manuscript.tags")
  local current_tags = tag_module.get(filepath)
  local choices = vim.deepcopy(config.preset_tags)

  for _, tag in ipairs(current_tags) do
    if not vim.tbl_contains(choices, tag) then
      table.insert(choices, tag)
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

    local function complete(tag_name)
      local updated = M.toggle_tag_on_file(filepath, tag_name)

      if updated and on_complete then
        on_complete(updated)
      end
    end

    if choice == "+ Add custom tag..." then
      vim.ui.input({
        prompt = "New tag name: ",
      }, function(input)
        if input and vim.trim(input) ~= "" then
          complete(input)
        end
      end)
    else
      complete(choice)
    end
  end)
end

local function open_chapter(chapter)
  if not chapter then
    return false
  end

  vim.cmd.edit(vim.fn.fnameescape(chapter.path))

  return true
end

function M.jump_to_chapter(query)
  if not config then
    vim.notify("myplugin: setup has not been called.", vim.log.levels.ERROR)
    return
  end

  local chapter_list = get_chapters()

  if #chapter_list == 0 then
    return
  end

  query = vim.trim(query or "")

  -- Numeric argument: jump directly to chapter.
  if query:match("^%d+$") then
    local chapter_number = tonumber(query)
    local chapter = chapter_list[chapter_number]

    if not chapter then
      vim.notify(
        string.format("Chapter %d not found. Available chapters: 1-%d.", chapter_number, #chapter_list),
        vim.log.levels.WARN
      )
      return
    end

    open_chapter(chapter)
    return
  end

  -- Text argument: open picker with initial search.
  require("myplugin.manuscript.picker").open(chapter_list, M.tag_chapter, query)
end

function M.chapters_by_tag(tag)
  if not config then
    vim.notify("myplugin: setup has not been called.", vim.log.levels.ERROR)
    return
  end

  local chapter_list = get_chapters()

  if #chapter_list == 0 then
    return
  end

  local tag_module = require("myplugin.manuscript.tags")
  local available_tags = {}

  -- Include preset tags.
  for _, preset in ipairs(config.preset_tags) do
    available_tags[preset] = true
  end

  -- Include custom tags already assigned to chapters.
  for _, chapter in ipairs(chapter_list) do
    for _, chapter_tag in ipairs(tag_module.get(chapter.path) or {}) do
      available_tags[chapter_tag] = true
    end
  end

  local tags = vim.tbl_keys(available_tags)
  table.sort(tags)

  local function open_tagged_chapters(selected_tag)
    local filtered = {}

    for _, chapter in ipairs(chapter_list) do
      local chapter_tags = tag_module.get(chapter.path) or {}

      if vim.tbl_contains(chapter_tags, selected_tag) then
        table.insert(filtered, chapter)
      end
    end

    if #filtered == 0 then
      vim.notify("No chapters found with tag: " .. selected_tag, vim.log.levels.INFO)
      return
    end

    require("myplugin.manuscript.picker").open(filtered, M.tag_chapter, nil)
  end

  tag = vim.trim(tag or "")

  if tag ~= "" then
    open_tagged_chapters(tag)
    return
  end

  if #tags == 0 then
    vim.notify("No chapter tags found.", vim.log.levels.INFO)
    return
  end

  vim.ui.select(tags, {
    prompt = "Select Chapter Tag:",
  }, function(choice)
    if choice then
      open_tagged_chapters(choice)
    end
  end)
end

function M.setup(opts)
  if is_setup then
    if opts then
      vim.notify("myplugin: setup has already run; restart Neovim to change configuration.", vim.log.levels.WARN)
    end

    return
  end

  config = require("myplugin.manuscript.config").setup(opts)
  is_setup = true

  -- Jump to chapter.
  vim.api.nvim_create_user_command("ChapterJump", function(command)
    M.jump_to_chapter(command.args)
  end, {
    nargs = "?",
    desc = "Search or jump to a manuscript chapter",
  })

  -- Manage current chapter tags.
  vim.api.nvim_create_user_command("ChapterTag", function(command)
    local filepath = vim.api.nvim_buf_get_name(0)

    if command.args ~= "" then
      M.toggle_tag_on_file(filepath, command.args)
    else
      M.tag_chapter(filepath)
    end
  end, {
    nargs = "?",
    complete = function()
      return config.preset_tags
    end,
    desc = "Toggle a tag on the current chapter",
  })

  -- Browse chapters by tag.
  vim.api.nvim_create_user_command("ChapterByTag", function(command)
    M.chapters_by_tag(command.args)
  end, {
    nargs = "?",
    complete = function()
      local chapter_list = get_chapters()

      if #chapter_list == 0 then
        return {}
      end

      local tag_module = require("myplugin.manuscript.tags")
      local available_tags = {}

      for _, preset in ipairs(config.preset_tags) do
        available_tags[preset] = true
      end

      for _, chapter in ipairs(chapter_list) do
        for _, tag in ipairs(tag_module.get(chapter.path) or {}) do
          available_tags[tag] = true
        end
      end

      return vim.tbl_keys(available_tags)
    end,
    desc = "Find and open chapters by tag",
  })
end

return M
