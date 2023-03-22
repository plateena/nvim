local opt = vim.opt
local g = vim.g
local o = vim.o

opt.autoindent = true
opt.smartindent = true
opt.wildmode="longest:list,full"
opt.list = true
opt.listchars:append "eol:↴"
opt.conceallevel=1
opt.concealcursor=""
opt.foldmethod="expr"
opt.scrolloff = 12

o.colorcolumn = '80'
o.cursorline = true     -- Highlight the current cursor line (Can slow the UI)
o.cursorcolumn = true     -- Highlight the current cursor line (Can slow the UI)
o.encoding = "utf-8"    -- Just in case
o.hidden = true         -- Allow multple buffers
o.history = 5000

o.hlsearch = false       -- Highlight search results
o.incsearch = true

o.ignorecase = true     -- Search ignoring case
o.mouse="i"             -- Enable mouse on insert mode

-- line number
o.number = true         -- Show numbers on the left
o.relativenumber = false -- Its better if you use motions like 10j or 5yk

o.shiftwidth = 0        -- Number of spaces to use for each step of (auto)indent
o.showmatch  = true     -- Highlights the matching parenthesis
o.showmode = false      -- Remove the -- INSERT -- message at the bottom
o.signcolumn = "yes"    -- Always show the signcolumn, otherwise it would shift the text
o.smartcase = true      -- Do not ignore case if the search patter has uppercase

o.swapfile = false      -- Do not leave any backup files
o.backup = false      -- Do not leave any backup files
o.undofile = true      -- Do not leave any backup files

o.expandtab = true      -- Use appropriate number of spaces (no so good for PHP but we can fix this in ft)
o.softtabstop = 4       -- On insert use 4 spaces for tab
o.tabstop = 4           -- Tab size of 4 spaces
o.shiftwidth = 4           -- Tab size of 4 spaces

o.termguicolors = true  -- Required for some themes

o.updatetime = 750      -- I have a modern machine. No need to wait that long
-- vim.o.splitright = true     -- New vert splits are on the right
-- vim.o.splitbelow = true     -- New horizontal splits, like `:help`, are on the bottom window
-- vim.o.cmdheight=2           -- Shows better messages
-- vim.o.wrap = false          -- Wrapping sucks (except on markdown)

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
