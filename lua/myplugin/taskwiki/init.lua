local M = {}

local function pad(str, width)
  return str .. string.rep(" ", math.max(0, width - #str))
end

local function get_tasks()
  local base_url = "https://inscaleasia.atlassian.net/browse"

  local cmd = [[
task status:pending jira_key.any: -hide -epic export | jq -r '
  .[]
  | select(.jira_key and .jira_stat)
  | (.id|tostring) + "|" + .jira_key + "|" + (.jira_stat | ascii_upcase) + "|" + .description
'
]]

  local lines = vim.fn.systemlist(cmd)

  local parsed = {}

  for _, line in ipairs(lines) do
    local id, key, stat, desc = line:match("^(.-)|(.+)|(.+)|(.+)$")
    if id and key and stat and desc then
      table.insert(parsed, {
        id = id,
        key = key,
        stat = stat,
        desc = desc,
      })
    end
  end

  local result = {}

  table.insert(result, "| # | ID | Jira | Status | Description |")
  table.insert(result, "|---|----|------|--------|------------|")

  for i, item in ipairs(parsed) do
    local key_link = string.format("[%s](%s/%s)", item.key, base_url, item.key)

    table.insert(result, string.format("| %d | %s | %s | %s | %s |", i, item.id, key_link, item.stat, item.desc))
  end

  return result
end

local function find_markers(lines)
  local start_idx, end_idx

  for i, line in ipairs(lines) do
    if line:match("TASKWARRIOR:START") then
      start_idx = i
    end
    if line:match("TASKWARRIOR:END") then
      end_idx = i
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

  local tasks = get_tasks()

  vim.api.nvim_buf_set_lines(buf, start_idx, end_idx - 1, false, tasks)
end

function M.setup()
  vim.keymap.set("n", "<leader>tj", function()
    M.update_block()
  end, { desc = "Insert Taskwarrior Jira tasks" })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = "*.md",
    callback = function()
      M.update_block()
    end,
  })
end

return M
