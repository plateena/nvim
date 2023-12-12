local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "morhetz/gruvbox",

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require(VG.config_dir .. 'nvim-treesitter')
        end
    },


    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    {
        'neovim/nvim-lspconfig',
        config = function()
            require(VG.root_dir .. 'lsp')
        end
    },
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    "hrsh7th/cmp-vsnip",
    {
        "hrsh7th/vim-vsnip",
        dependencies = {
            "hrsh7th/vim-vsnip-integ",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            -- require("simple.plugin.vsnip")
        end,
    },
    "jcha0713/cmp-tw2css",
    "delphinus/cmp-ctags",
    { 
        'hrsh7th/nvim-cmp',
        config = function() 
            require(VG.config_dir .. 'nvim-cmp')
        end
    },

    "lambdalisue/suda.vim",


    -- " For vsnip users.,
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',

    {
        'nvim-lualine/lualine.nvim',
        config = function()
            require(VG.root_dir.. '.config.lualine')
        end
    },
    'nvim-tree/nvim-web-devicons',

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.4",
        dependencies = { { "nvim-lua/plenary.nvim"} },
        config = function() 
            require(VG.config_dir .. 'telescope')
        end
    },
    { "preservim/tagbar" },
    { "mattn/emmet-vim" },
    {
        "nvim-tree/nvim-tree.lua", 
        config = function()
            require(VG.config_dir .. 'nvim-tree')
        end
    },
    "lukas-reineke/indent-blankline.nvim",
    "tpope/vim-fugitive",
    "delphinus/cmp-ctags",

    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
        config = function()
            require('Comment').setup()
        end
    },

    {
        'neovim/nvim-lspconfig',
        config = function()
            require(VG.root_dir .. 'lsp')
        end
    },
    'jose-elias-alvarez/null-ls.nvim',
    'MunifTanjim/prettier.nvim',
    {
        "folke/which-key.nvim",
        config = function() 
            require(VG.root_dir .. '.config.which-key')
        end
    },

})
