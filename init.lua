vim.env.PATH = vim.fn.expand("$HOME/.rbenv/shims:") .. vim.env.PATH
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
vim.g.loaded_perl_provider = 0
vim.g.python3_host_prog = vim.fn.expand("$HOME/.pyenv/versions/nvim-venv/bin/python")

require("config/keymaps")
require("config/options")
require("config/macros")

-- define which version of config
require("v5")
