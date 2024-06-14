return {
    "m4xshen/hardtime.nvim",
    enabled = false,
    config = function()
        require("hardtime").setup({
            -- disabled_filetypes = { "NvimTree", "lazy", "mason" },
        })
    end
}
