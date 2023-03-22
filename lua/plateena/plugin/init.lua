require("plateena.plugins")
require("plateena.plugin.telescope")
require("plateena.plugin.lsp")

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])
