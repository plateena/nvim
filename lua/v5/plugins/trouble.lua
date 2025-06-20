return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
        modes = {
            diagnostics_buffer = {
                mode = "diagnostics",
                filter = { buf = 0 },
            },
        },
    },
}
