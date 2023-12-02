-- Get the path of the current script
local script_path = debug.getinfo(1, "S").source:sub(2)
-- Extract the folder name
local current_path = vim.fn.fnamemodify(script_path, ":h")
-- Extract the folder name from the path
local config_folder = vim.fn.fnamemodify(current_path, ":t")

vG = {}

vG.root_dir = config_folder


-- Load autocmds from the 'plateena' folder
require(config_folder .. '/autocmds')

-- Load mappings from the 'plateena' folder
require(config_folder .. '/mappings')

-- Load additional Lua configurations from the 'plateena' folder
require(config_folder .. '/myconfig')

require(config_folder .. '/myplugins')
