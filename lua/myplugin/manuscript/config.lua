local M = {}

M.defaults = {
  dir = "manuscript/ms",
  extensions = { "md", "txt" },
  allow_extensionless = true,
  preset_tags = { "draft", "reviewed", "locked", "publish" },
}

function M.setup(opts)
  local config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})

  -- Validate directories
  if type(config.dir) == "string" then
    assert(config.dir ~= "", "myplugin: 'dir' must be a non-empty string")
    config.dir = { config.dir }
  end

  assert(
    type(config.dir) == "table" and #config.dir > 0,
    "myplugin: 'dir' must be a non-empty string or non-empty table"
  )

  for _, dir in ipairs(config.dir) do
    assert(type(dir) == "string" and dir ~= "", "myplugin: every 'dir' entry must be a non-empty string")
  end

  assert(type(config.extensions) == "table", "myplugin: 'extensions' must be a table")
  assert(type(config.preset_tags) == "table", "myplugin: 'preset_tags' must be a table")

  local extensions = {}
  for _, extension in ipairs(config.extensions) do
    local clean = tostring(extension):lower():gsub("^%.", "")
    if clean ~= "" and not vim.tbl_contains(extensions, clean) then
      table.insert(extensions, clean)
    end
  end
  config.extensions = extensions

  local tags = {}
  for _, tag in ipairs(config.preset_tags) do
    local clean = vim.trim(tostring(tag)):lower()
    if clean ~= "" and not vim.tbl_contains(tags, clean) then
      table.insert(tags, clean)
    end
  end
  config.preset_tags = tags

  return config
end

return M
