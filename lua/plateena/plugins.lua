
local pack = require("plateena.utils.packer-loaded")

return require('packer').startup(function(use)
    use {
        'wbthomason/packer.nvim',

        -- colorscheme
        "savq/melange-nvim",
        "Shatur/neovim-ayu",

        {'nvim-telescope/telescope.nvim', tag = '0.1.1',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    "tpope/vim-fugitive",

    "folke/which-key.nvim",
}

if pack.ensure_packer then
    require('packer').sync()
end
end)
