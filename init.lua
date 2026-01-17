vim.env.PATH = vim.fn.expand("$HOME/.rbenv/shims:") .. vim.env.PATH

require("config/keymaps")
require("config/options")
require("config/macros")

-- define which version of config
require("v5")
