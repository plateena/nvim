local M = {}

local function normalize_path(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p"):gsub("/$", "")
end

function M.resolve_dirs(config)
  local directories = {}

  for _, dir in ipairs(config.dir or {}) do
    local path = normalize_path(dir)

    if vim.fn.isdirectory(path) == 1 then
      if not vim.tbl_contains(directories, path) then
        table.insert(directories, path)
      end
    end
  end

  return directories
end

function M.list(directories, config)
  local chapters = {}
  local seen = {}

  local extensions = {}

  for _, extension in ipairs(config.extensions or {}) do
    extensions[extension:gsub("^%.", "")] = true
  end

  for _, directory in ipairs(directories) do
    local files = vim.fn.globpath(directory, "**/*", false, true)

    for _, filepath in ipairs(files) do
      if vim.fn.filereadable(filepath) == 1 then
        local extension = filepath:match("%.([^./]+)$")

        local allowed = extension and extensions[extension] or (not extension and config.allow_extensionless)

        local normalized = normalize_path(filepath)

        if allowed and not seen[normalized] then
          seen[normalized] = true

          table.insert(chapters, {
            path = normalized,
            filename = vim.fn.fnamemodify(filepath, ":t"),
            name = vim.fn.fnamemodify(filepath, ":t:r"),
            directory = directory,
          })
        end
      end
    end
  end

  table.sort(chapters, function(a, b)
    return a.path < b.path
  end)

  return chapters
end

return M
