return {
    "xiyaowong/transparent.nvim",
    config = function()
        local transparent = require("transparent")
        transparent.clear_prefix("BufferLine")
        transparent.clear_prefix("NvimTree")
        -- transparent.clear_prefix("lualine")
        transparent.clear_prefix("Telescope")
        transparent.clear_prefix("Harpoon")
    end,
}
