local pack = require("plateena.utils.packer-loaded")

return require('packer').startup(function(use)
    use {
        'wbthomason/packer.nvim',

        -- colorscheme
        "savq/melange-nvim",
        "Shatur/neovim-ayu",
        { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },

        -- search and navigation
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.1',
            -- or                            , branch = '0.1.x',
            requires = { { 'nvim-lua/plenary.nvim' } }
        },

        -- layout
        --         {
        --             'nvim-lualine/lualine.nvim',
        --             requires = {
        --                 'SmiteshP/nvim-navic',
        --             }
        --         },
        {
            'glepnir/galaxyline.nvim',
            branch = 'main',
            -- your statusline
            config = function()
                require('plateena.plugin.galaxyline')
            end,
            -- some optional icons
            requires = { 'nvim-tree/nvim-web-devicons', opt = true },
        },

        -- lsp
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",

        -- git
        "tpope/vim-fugitive",

        "folke/which-key.nvim",

        -- dependences icons
        'nvim-tree/nvim-web-devicons',
        'onsails/lspkind.nvim',

        -- autocomplete
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-vsnip',
        {
            'hrsh7th/vim-vsnip',
            requires = {
                'hrsh7th/vim-vsnip-integ',
                "rafamadriz/friendly-snippets",
            },
            config = function()
                vim.cmd("let g:vsnip_snippet_dir='" .. vim.fn.stdpath("config") .. "lua/plateena/snippets'")
            end
        },
        'jcha0713/cmp-tw2css',
        'delphinus/cmp-ctags',
    }

    if pack.ensure_packer then
        require('packer').sync()
    end
end)
