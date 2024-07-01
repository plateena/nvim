return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    config = function()
        local trouble = require('trouble')
        trouble.setup({
            modes = {
                diagnostics_buffer = {
                    mode = "diagnostics",
                    filter = { buf = 0 },
                }
            }
        })
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
}
