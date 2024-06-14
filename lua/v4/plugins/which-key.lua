return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.opt.timeout = true
        vim.opt.timeoutlen = 500
    end,
    opts = {
        operators = {
            ["<leader>b"] = "Buffer"
        },
    },
    config = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end

        which_key.register({}, {})
    end,

    vim.keymap.set('n', '<Leader>b', '', { desc = "Buffer" }),
    vim.keymap.set('n', '<Leader>f', '', { desc = "Telescope" }),
    vim.keymap.set('n', '<Leader>e', '', { desc = "Nerd Tree" }),
}
