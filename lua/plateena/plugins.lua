
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

    'nvim-tree/nvim-web-devicons',
    'onsails/lspkind.nvim',

    -- autocomplete
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'jcha0713/cmp-tw2css',
    'delphinus/cmp-ctags',
}

if pack.ensure_packer then
    require('packer').sync()
end
end)
