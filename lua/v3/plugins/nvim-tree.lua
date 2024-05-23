return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        -- examples for your init.lua

        -- disable netrw at the very start of your init.lua (strongly advised)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- set termguicolors to enable highlight groups
        vim.opt.termguicolors = true

        -- OR setup with some options
        require("nvim-tree").setup({
            sort_by = "name",
            update_focused_file = {
                enable = true,
                update_cwd = true,
            },
            renderer = {
                root_folder_modifier = ":t",
                icons = {
                    glyphs = {
                        -- default = "",
                        -- symlink = "",
                        folder = {
                            arrow_open = "",
                            arrow_closed = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "",
                            staged = "S",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "U",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = {
                    hint = "",
                    info = "",
                    warning = "",
                    error = "",
                },
            },
            view = {
                width = 40,
                side = "left",
                number = true,
                relativenumber = true,
                signcolumn = "yes",
                -- mappings = {
                --     list = {
                -- { key = { "l", "<CR>", "o" }, cb = tree_cb "edit" },
                -- { key = "h", cb = tree_cb "close_node" },
                -- { key = "v", cb = tree_cb "vsplit" },
                --     },
                -- },
            },
            filters = {
                dotfiles = false,
                git_clean = false,
                no_buffer = false,
                custom = {},
                exclude = {},
            },
        })

        vim.keymap.set("n", "<leader>et", "<Cmd>NvimTreeToggle<Cr>", { desc = "Nvim tree toggle" })
        vim.keymap.set("n", "<leader>ef", "<Cmd>NvimTreeFindFileToggle<Cr>", { desc = "Nvim tree find file toggle" })
    end,
}
