-- Get the path of the current script
local script_path = debug.getinfo(1, "S").source:sub(2)
-- Extract the folder name
local current_path = vim.fn.fnamemodify(script_path, ":h")

-- Extract the folder name from the path
local config_folder = vim.fn.fnamemodify(current_path, ":t")


VG = {}

VG.root_dir = config_folder .. '.'
VG.config_dir = VG.root_dir .. 'config.'

require(config_folder .. '/plugins')

function PrintAllVimGValues()
    for key, value in pairs(vim.g) do
        print(key, value)
    end
end
