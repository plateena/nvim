-- Load individual configurations

-- ========================
-- UI and Visual Enhancements
-- ========================
-- Telescope configuration
require(vG.root_dir .. '.config.telescope')

-- Lualine configuration
require(vG.root_dir .. '.config.lualine')

-- nvim-tree configuration
require(vG.root_dir .. '.config.nvim-tree')

-- ========================
-- Language Support and Snippets
-- ========================
-- LSP configuration
require(vG.root_dir .. '.config.lsp')

-- Mason configuration for snippets
require("mason").setup()

-- vim-vsnip configuration
require(vG.root_dir .. '.config.vsnip')

require(vG.root_dir .. '.config.which-key')

-- ========================
-- Syntax Highlighting and Context-aware Comments
-- ========================
-- nvim-treesitter configuration
require(vG.root_dir .. '.config.nvim-treesitter')

-- Context-aware comments with ts-context-commentstring
vim.g.skip_ts_context_commentstring_module = true
require('ts_context_commentstring').setup {}
