return {
    "MeanderingProgrammer/render-markdown.nvim",
    -- enabled = false,
    ft = { "markdown", "vimwiki" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "echasnovski/mini.nvim", -- or mini.icons / nvim-web-devicons
    },
    opts = {
        file_types = { "vimwiki" },
    },
    config = function(_, opts)
        require("render-markdown").setup(opts)
        vim.treesitter.language.register("markdown", "vimwiki")
    end,
}
