-- Get the path of the current script
local script_path = debug.getinfo(1, "S").source:sub(2)
-- Extract the folder name
local current_path = vim.fn.fnamemodify(script_path, ":h")

print("Current folder:", current_path)

-- Extract the folder name from the path
local current_folder = vim.fn.fnamemodify(current_path, ":t")

print("Current folder:", current_folder)
