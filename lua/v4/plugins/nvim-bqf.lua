return {
    "kevinhwang91/nvim-bqf",
    enabled = true,
    dependencies = {
        {
            "junegunn/fzf",
            build = function()
                vim.fn["fzf#install"]()
            end,
        },
    },
    event = "VeryLazy",
    ft = { "qf", "lf" },
    opts = {},
    config = function()
        require("bqf").setup({})
    end,
}
