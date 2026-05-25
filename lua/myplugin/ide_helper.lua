local M = {}

local helper_file = "_ide_helper_models.php"

--- Get the class name from the variable under cursor by checking LSP hover or buffer context
local function get_class_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  -- Match $variable->method() pattern, grab variable name
  local var = line:match("%$([%w_]+)%s*%->[%w_]+")
  if not var then
    -- Try ClassName::method() pattern
    local class = line:match("([A-Z][%w_\\]+)%s*::")
    return class
  end

  -- Search backwards for type hint: ClassName $var
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.fn.line(".") - 1

  for i = cursor_line, math.max(0, cursor_line - 30), -1 do
    local l = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ""
    local class = l:match("([A-Z][%w_\\]+)%s+%$" .. var)
    if class then return class end
    -- Also check @var annotation
    class = l:match("@var%s+\\?([A-Z][%w_\\]+)%s+%$" .. var)
    if class then return class end
  end

  return nil
end

--- Get the method name under cursor
local function get_method_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col(".")

  -- Match ->method( or ::method(
  local method = line:match("->([%w_]+)%s*%(") or line:match("::([%w_]+)%s*%(")
  return method
end

--- Find the helper file path
local function get_helper_path()
  local root = vim.fn.findfile(helper_file, ".;")
  if root == "" then
    root = vim.fn.getcwd() .. "/" .. helper_file
  end
  return root
end

--- Add a @method annotation to the helper file for a given class
function M.add_method_stub()
  local class = get_class_at_cursor()
  local method = get_method_at_cursor()

  if not method then
    vim.notify("No method found under cursor", vim.log.levels.WARN)
    return
  end

  -- Prompt for return type
  vim.ui.input({ prompt = "Return type (default: mixed): " }, function(return_type)
    if return_type == nil then return end
    if return_type == "" then return_type = "mixed" end

    -- Prompt for parameters
    vim.ui.input({ prompt = "Parameters (e.g. $key, $default = null): " }, function(params)
      if params == nil then return end

      local annotation = string.format(" * @method %s %s(%s)", return_type, method, params)
      local fqcn = class or "UnknownClass"

      local path = get_helper_path()
      local lines = {}
      local file = io.open(path, "r")

      if file then
        for line in file:lines() do
          lines[#lines + 1] = line
        end
        file:close()
      end

      -- Find the class in the file and insert the annotation
      local inserted = false
      local namespace_pattern = fqcn:match("\\") and fqcn:gsub("\\[^\\]+$", "") or nil
      local class_name = fqcn:match("([^\\]+)$") or fqcn

      for i, line in ipairs(lines) do
        if line:match("class%s+" .. class_name) then
          -- Find the docblock above it, insert before closing */
          for j = i - 1, 1, -1 do
            if lines[j]:match("%*/") then
              table.insert(lines, j, annotation)
              inserted = true
              break
            end
            if lines[j]:match("/%*%*") then
              table.insert(lines, j + 1, annotation)
              inserted = true
              break
            end
          end
          if not inserted then
            -- No docblock, create one
            table.insert(lines, i, " */")
            table.insert(lines, i, annotation)
            table.insert(lines, i, "/**")
            inserted = true
          end
          break
        end
      end

      if not inserted then
        -- Class not found in file, append a new block
        lines[#lines + 1] = ""
        lines[#lines + 1] = "namespace App\\Models {"
        lines[#lines + 1] = "/**"
        lines[#lines + 1] = annotation
        lines[#lines + 1] = " */"
        lines[#lines + 1] = string.format("class %s {}", class_name)
        lines[#lines + 1] = "}"
      end

      file = io.open(path, "w")
      if file then
        file:write(table.concat(lines, "\n") .. "\n")
        file:close()
        vim.notify(string.format("Added @method %s to %s in %s", method, class_name, helper_file), vim.log.levels.INFO)
      else
        vim.notify("Failed to write " .. path, vim.log.levels.ERROR)
      end
    end)
  end)
end

--- Quick add: uses word under cursor as method, prompts for class/return/params
function M.quick_add()
  local method = get_method_at_cursor()
  local class = get_class_at_cursor()

  if not method then
    vim.notify("No method found under cursor", vim.log.levels.WARN)
    return
  end

  local prompt_class = class or ""
  vim.ui.input({ prompt = "Class: ", default = prompt_class }, function(input_class)
    if not input_class or input_class == "" then return end
    -- Override class for the stub
    local orig = get_class_at_cursor
    get_class_at_cursor = function() return input_class end
    M.add_method_stub()
    get_class_at_cursor = orig
  end)
end

-- Commands
vim.api.nvim_create_user_command("IdeHelperAdd", M.add_method_stub, { desc = "Add method stub to _ide_helper_models.php" })
vim.api.nvim_create_user_command("IdeHelperQuickAdd", M.quick_add, { desc = "Add method stub (prompts for class)" })

-- Keymap (only for PHP files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function(args)
    vim.keymap.set("n", "<leader>ci", M.add_method_stub, { buffer = args.buf, desc = "Add method to IDE helper" })
    vim.keymap.set("n", "<leader>cI", M.quick_add, { buffer = args.buf, desc = "Add method to IDE helper (pick class)" })
  end,
})

return M
