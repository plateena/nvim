return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup({
            override_by_extension = {
                ["blade.php"] = {
                    icon = "󰫐",
                    color = "#fa3629",
                    name = "Blade",
                }
            }
        })
    end,
}
