local packer = require("packer")

packer.startup(function(use)
    -- Packer itself
    use "wbthomason/packer.nvim"

    -- Utility Functions
    local function use_with_config(name, config)
        use { name, config = config }
    end

    local function use_with_run(name, fn)
        use { name, run = fn }
    end

    local function use_with_dependencies(name, dependencies)
        use { name, requires = dependencies }
    end

    -- Essential Plugins
    use {
        "tpope/vim-fugitive",    -- Git commands
        "neovim/nvim-lspconfig", -- Language Server Protocol configurations
    }

    use { "jose-elias-alvarez/null-ls.nvim" }

    -- UI and File Management
    use_with_dependencies("nvim-telescope/telescope.nvim", {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim", -- FZF native integration
            run = "make",
        },
    })
    use "nvim-tree/nvim-tree.lua" -- File Explorer

    use "folke/which-key.nvim"

    -- Snippets and Completion
    use_with_dependencies("hrsh7th/vim-vsnip", {
        "hrsh7th/vim-vsnip-integ",
        "rafamadriz/friendly-snippets",
    })
    use_with_dependencies("hrsh7th/nvim-cmp", {
        "hrsh7th/cmp-nvim-lsp", -- LSP source for cmp
    })

    -- Syntax Highlighting and Treesitter
    use_with_run("nvim-treesitter/nvim-treesitter", function()
        vim.cmd(":TSUpdate")
    end)

    -- Theming
    local themes = {
        "morhetz/gruvbox",
        "tomasr/molokai",
        "dracula/vim",
        "savq/melange-nvim",
        "Shatur/neovim-ayu",
        "EdenEast/nightfox.nvim",
    }
    use(themes)

    -- Statusline and Icons
    use_with_dependencies("nvim-lualine/lualine.nvim", {
        "nvim-tree/nvim-web-devicons", opt = true,
    })

    -- Context-aware Comments
    use "JoosepAlviste/nvim-ts-context-commentstring"

    -- Commenting Plugin
    use_with_config("numToStr/Comment.nvim", function()
        require("Comment").setup({
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
    end)

    -- Suda for elevated write
    use "lambdalisue/suda.vim"

    -- Mason
    use "williamboman/mason.nvim"
end)
