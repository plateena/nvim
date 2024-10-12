-- require("plateena")
require("config/keymaps")
require("config/options")

vim.env.PATH = vim.fn.expand("$HOME/.rbenv/shims:") .. vim.env.PATH

-- define which version of config
require("v4")
