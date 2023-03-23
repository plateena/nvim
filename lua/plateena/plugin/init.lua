require("plateena.plugins")
require("plateena.plugin.telescope")
require("plateena.plugin.lsp")
require("plateena.plugin.which-key")
require("plateena.plugin.nvim-cmp")

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])
