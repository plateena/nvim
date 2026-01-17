return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    init = function()
        vim.opt.timeout = true
        vim.opt.timeoutlen = 500
    end,
    opts = {
        operators = {
            ["<leader>b"] = "Buffer",
        },
    },
    config = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end

        which_key.setup({
            preset = "modern",
        })

        which_key.add({
            { "<leader>b", group = "Buffer" },
            { "<leader>e", group = "Nerd Tree" },
            { "<leader>f", group = "Telescope" },

            { "<leader>o", group = "Options" },
            { "<leader>oy", group = "Yank" },
            { "<leader>oyi", "<Cmd>setlocal paste<Cr>", desc = "Set paste true" },
            { "<leader>oyo", "<Cmd>setlocal nopaste<Cr>", desc = "Set paste false" },
            {
                "<leader>oh",
                function()
                    vim.o.hlsearch = not vim.o.hlsearch
                    print("hlsearch: " .. (vim.o.hlsearch and "on" or "off"))
                end,
                desc = "Toggle hlsearch",
            },
        })
        vim.api.nvim_set_hl(0, "WhichKey", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeySeperator", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
    end,
}
