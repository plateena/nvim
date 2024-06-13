return {
    "m4xshen/hardtime.nvim",
    config = function()
        require("hardtime").setup({
            -- disabled_filetypes = { "NvimTree", "lazy", "mason" },
        })
    end
}
