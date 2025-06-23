local opt = vim.opt
local g = vim.g
local api = vim.api

g.OmniSharp_server_stdio = 0

opt.list = true
opt.listchars:append "space:⋅"
opt.listchars:append "eol:↴"
-- opt.clipboard:append('unnamedplus')

opt.autoindent = true
opt.smartindent = true
opt.wildmode="longest:list,full"
opt.conceallevel=1
opt.concealcursor=""
opt.foldmethod="expr"
opt.scrolloff = 4 -- add line so the cursor will not at the top of screen / line

opt.colorcolumn = '120'
opt.cursorline = true     -- Highlight the current cursor line (Can slow the UI)

opt.cursorcolumn = true     -- Highlight the current cursor line (Can slow the UI)
opt.encoding = "utf-8"    -- Just in case
opt.hidden = true         -- Allow multple buffers
opt.history = 5000
opt.completeopt = "longest,menu,preview"


opt.hlsearch = false       -- Highlight search results
opt.incsearch = true

opt.ignorecase = true     -- Search ignoring case
opt.mouse="i"             -- Enable mouse on insert mode

-- line number
opt.number = true         -- Show numbers on the left
opt.relativenumber = true -- Its better if you use motions like 10j or 5yk

opt.shiftwidth = 0        -- Number of spaces to use for each step of (auto)indent
opt.showmatch  = true     -- Highlights the matching parenthesis
opt.showmode = false      -- Remove the -- INSERT -- message at the bottom
opt.signcolumn = "yes"    -- Always show the signcolumn, otherwise it would shift the text
opt.smartcase = true      -- Do not ignore case if the search patter has uppercase

opt.swapfile = false      -- Do not leave any backup files
opt.backup = false      -- Do not leave any backup files
opt.undofile = true      -- Do not leave any backup files

opt.expandtab = true      -- Use appropriate number of spaces (no so good for PHP but we can fix this in ft)
opt.softtabstop = 4       -- On insert use 4 spaces for tab
opt.tabstop = 4           -- Tab size of 4 spaces
opt.shiftwidth = 4           -- Tab size of 4 spaces

opt.termguicolors = true  -- Required for some themes
opt.background = "dark"

opt.updatetime = 50      -- I have a modern machine. No need to wait that long
-- opt.splitright = true     -- New vert splits are on the right
-- opt.splitbelow = true     -- New horizontal splits, like `:help`, are on the bottom window
-- opt.cmdheight=2           -- Shows better messages
-- opt.wrap = false          -- Wrapping sucks (except on markdown)

-- set list chars
local list_chars_symbols = {
	-- ["eol"] = "↲",
	["eol"] = "↴",
	["tab"] = "→ ",
	-- ["tab"] = "» ",
	-- ["space"] = "␣",
	["trail"] = "-",
	-- ["extends"] = "☛",
	-- ["precedes"] = "☚",
	["extends"] = "»",
	["precedes"] = "«",
	["conceal"] = "┊",
	-- ["nbsp"] = "☠",
	["nbsp"] = "⣿",
}

for k, v in pairs(list_chars_symbols) do
	opt.listchars:append(k .. ":" .. v)
end

local disabled_built_ins = {
	"2html_plugin",
	"getscript",
	"getscriptPlugin",
	"gzip",
	"logipat",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"matchit",
	"tar",
	"tarPlugin",
	"rrhelper",
	"spellfile_plugin",
	"vimball",
	"vimballPlugin",
	"zip",
	"zipPlugin",
	"tutor",
	"rplugin",
	"syntax",
	"synmenu",
	"optwin",
	"compiler",
	"bugreport",
	"ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
	g["loaded_" .. plugin] = 1
end

-- Add this at the top of your config
g.format_on_save_enabled = false

