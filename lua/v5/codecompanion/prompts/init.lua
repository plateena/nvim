local M = {}

local prompt_dir = vim.fn.stdpath("config") .. "/lua/v5/prompts"
local files = vim.fn.glob(prompt_dir .. "/*.lua", false, true)

for _, file in ipairs(files) do
  local name = file:match("([^/]+)%.lua$")
  if name ~= "init" then
    local prompts = require("v5.prompts." .. name)
    for key, value in pairs(prompts) do
      M[key] = value
    end
  end
end

return M
