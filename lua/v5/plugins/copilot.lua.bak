return {
    "zbirenbaum/copilot.lua",
    ft = { 'php', 'javascript', 'ruby', 'typescript', 'lua' },
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter", -- optional, depending on load behavior you want
    config = function()
        require("copilot").setup({
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    accept = "<C-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            panel = {
                enabled = true,
                auto_refresh = true,
                keymap = {
                    open = "<M-CR>",
                    accept = "<CR>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    refresh = "gr",
                    close = "<Esc>",
                },
                filetypes = {
                    markdown = false,
                    yaml = false,
                    gitcommit = false,
                },
            },
        })
    end,
}
