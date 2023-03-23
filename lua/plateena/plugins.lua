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
            requires = { { 'nvim-lua/plenary.nvim' } },
            config = function()
                require("plateena.plugin.telescope")
            end
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
        {
            'nvim-tree/nvim-tree.lua',
            config = function()
                require("plateena.plugin.nvim-tree")
            end
        },

        -- lsp
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",

        -- git
        "tpope/vim-fugitive",
        {
            'lewis6991/gitsigns.nvim',
            config = function()
                require('plateena.plugin.gitsigns')
            end
        },

        {
            "folke/which-key.nvim",
            config = function()
                require("plateena.plugin.which-key")
            end
        },
        {"gbprod/phpactor.nvim",
        config = function ()
            require("plateena.plugin.phpactor")
        end
    },

        -- dependences icons
        'nvim-tree/nvim-web-devicons',
        'onsails/lspkind.nvim',

        -- autocomplete
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
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
        {
            'hrsh7th/nvim-cmp',
            config = function()
                require("plateena.plugin.nvim-cmp")
            end
        },

        -- editing
        {
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup()
            end
        },
        'JoosepAlviste/nvim-ts-context-commentstring',
        {
            'numToStr/Comment.nvim',
            config = function()
                require('Comment').setup({
                    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
                })
            end
        },
        "lambdalisue/suda.vim",

        -- test
        {
            "klen/nvim-test",
            config = function()
                require('nvim-test').setup({})
            end
        }
    }

    if pack.ensure_packer then
        require('packer').sync()
    end
end)
