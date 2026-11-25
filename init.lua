vim.env.PATH = vim.fn.expand("$HOME/.rbenv/shims:") .. vim.env.PATH
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
vim.g.loaded_perl_provider = 0
vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim-venv/bin/python")
local codex_bin = vim.fn.expand("~/.config/nvm/versions/node/v24.11.0/bin")

vim.env.PATH = codex_bin .. ":" .. vim.env.PATH

require("config/keymaps")
require("config/options")
require("config/macros")
require("config/autocmds")
require("config/cheatsheet")

math.randomseed(os.time())

require("v6")
