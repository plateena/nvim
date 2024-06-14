return {
    "m4xshen/hardtime.nvim",
    enabled = function()
        if vim.fn.has("nvim-0.10.0") then
            return true
        end
        return false
    end,
    config = function()
        require("hardtime").setup({
            disabled_filetypes = { "NvimTree", "lazy", "mason", "lf", "qf", "quickfix", "loclist" },
        })
    end,
}
