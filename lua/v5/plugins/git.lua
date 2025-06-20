return {
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<Leader>g", "", { desc = "Git" })
            vim.keymap.set("n", "<Leader>gs", "<Cmd>Git<Cr>", { desc = "Git" })
            vim.keymap.set("n", "<Leader>gP", "<Cmd>Git pull<Cr>", { desc = "Git pull" })
            vim.keymap.set("n", "<Leader>gv", "<Cmd>Gvdiffsplit<Cr>", { desc = "Git diff split" })

            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    if vim.wo.diff then
                        vim.keymap.set("n", "<Leader>gh", "<Cmd>diffget //2<Cr>", { desc = "diffget //2" })
                        vim.keymap.set("n", "<Leader>gl", "<Cmd>diffget //3<Cr>", { desc = "diffget //3" })
                        vim.keymap.set("n", "<Leader>gu", "<Cmd>diffput //2<Cr>", { desc = "diffput //2" })
                        vim.keymap.set("n", "<Leader>gi", "<Cmd>diffput //3<Cr>", { desc = "diffput //3" })
                    end
                end
            })
        end,
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        }
    },
    {
        "lewis6991/gitsigns.nvim",
        enabled = true,
        config = function()
            local gitsigns = require("gitsigns")
            gitsigns.setup({
                signs = {
                    add = { text = "┃" },
                    change = { text = "┃" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked = { text = "┆" },
                },
                signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
                numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
                linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
                word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir = {
                    follow_files = true,
                },
                auto_attach = true,
                attach_to_untracked = false,
                current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                    delay = 1000,
                    ignore_whitespace = false,
                    virt_text_priority = 100,
                },
                current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil,  -- Use default
                max_file_length = 40000, -- Disable if file is longer than this (in lines)
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = "single",
                    style = "minimal",
                    relative = "cursor",
                    row = 0,
                    col = 1,
                },
            })
        end,
    },
}
