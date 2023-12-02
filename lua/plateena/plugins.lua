local pack = require("plateena.utils.packer-loaded")

return require("packer").startup(function(use)
    -- colorscheme

    -- search and navigation
    -- or                            , branch = '0.1.x',
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below

    -- layout
    --         {
    --             'nvim-lualine/lualine.nvim',
    --             requires = {
    --                 'SmiteshP/nvim-navic',
    --             }
    --         },
    -- your statusline
    -- some optional icons

    -- lsp

    -- git

    -- dependences icons

    -- autocomplete

    -- editing

    -- test
    -- {
    --     "klen/nvim-test",
    --     config = function()
    --         require('plateena.plugin.nvim-test')
    --     end
    -- },
    -- require('packer').sync()
    use({
        "wbthomason/packer.nvim",
        "morhetz/gruvbox",
        "tomasr/molokai",
        "dracula/vim",
        "savq/melange-nvim",
        "Shatur/neovim-ayu",
        { "EdenEast/nightfox.nvim" },
        {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            after = "nvim-treesitter",
            requires = "nvim-treesitter/nvim-treesitter",
        },
        { "nvim-telescope/telescope-ui-select.nvim" },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            run = "make",
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.1",
            requires = { { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" } },
            config = function()
                require("plateena.plugin.telescope")
            end,
        },
        { "preservim/tagbar" },
        { "mattn/emmet-vim" },
        {
            "folke/trouble.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                require("plateena.plugin.lsp.trouble")
            end,
        },
        {
            "folke/todo-comments.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
            opts = {},
            config = function()
                require("plateena.plugin.todo-comments")
            end,
        },
        "ap/vim-css-color",
        {
            "glepnir/galaxyline.nvim",
            branch = "main",
            config = function()
                require("plateena.plugin.galaxyline")
            end,
            requires = { {
                "nvim-tree/nvim-web-devicons",
                opt = true,
            } },
        },
        {
            "nvim-tree/nvim-tree.lua",
            config = function()
                require("plateena.plugin.nvim-tree")
            end,
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            config = function()
                require("plateena.plugin.indent-blankline")
            end,
        },
        {
            "anuvyklack/pretty-fold.nvim",
            config = function()
                require("pretty-fold").setup({})
            end,
        },
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        {
            "neovim/nvim-lspconfig",
            config = function()
                require("plateena.plugin.lsp")
            end,
        },
        {
            "jose-elias-alvarez/null-ls.nvim",
            config = function()
                -- require("plateena.plugin.lsp.null_ls")
            end,
        },
        "tpope/vim-fugitive",
        {
            "lewis6991/gitsigns.nvim",
            config = function()
                require("plateena.plugin.gitsigns")
            end,
        },
        {
            "folke/which-key.nvim",
            config = function()
                require("plateena.plugin.which-key")
            end,
        },
        {
            "gbprod/phpactor.nvim",
            config = function()
                require("plateena.plugin.phpactor")
            end,
        },
        "nvim-tree/nvim-web-devicons",
        "onsails/lspkind.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-vsnip",
        {
            "hrsh7th/vim-vsnip",
            requires = {
                "hrsh7th/vim-vsnip-integ",
                "rafamadriz/friendly-snippets",
            },
            config = function()
                require("plateena.plugin.vsnip")
            end,
        },
        "jcha0713/cmp-tw2css",
        "delphinus/cmp-ctags",
        {
            "hrsh7th/nvim-cmp",
            config = function()
                require("plateena.plugin.nvim-cmp")
            end,
        },
        {
            "kylechui/nvim-surround",
            config = function()
                require("nvim-surround").setup({
                    keymaps = {
                        insert = "<C-g>s",
                        insert_line = "<C-g>S",
                        normal = "sy",
                        normal_cur = "ssy",
                        normal_line = "Sy",
                        normal_cur_line = "SSy",
                        visual = "S",
                        visual_line = "gS",
                        delete = "sd",
                        change = "sc",
                    },
                })
            end,
        },
        "JoosepAlviste/nvim-ts-context-commentstring",
        {
            "numToStr/Comment.nvim",
            config = function()
                require("Comment").setup({
                    pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
                })
            end,
        },
        "lambdalisue/suda.vim",
        "tpope/vim-dispatch",
        {
            "nyngwang/NeoZoom.lua",
            config = function()
                require("plateena.plugin.neozoom")
            end,
        },
        {
            "akinsho/toggleterm.nvim",
            tag = "*",
            config = function()
                require("plateena.plugin.toggleterm")
            end,
        },
    })

    if pack.ensure_packer then
    end
end)
