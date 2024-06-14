return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function ()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        local builtin =  require('telescope.builtin')

        telescope.setup({
            defaults = {
                path_display = { shorten = { len = 3 } },
                prompt_prefix = "  ",
                selection_caret = " ❯ ",
                mappings = {
                    i = {
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<C-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
                    }
                }
            },
            pickers = {
                find_files = {
                    find_command = {
                        "fd",
                        "-t",
                        "f",
                        "--hidden",
                        "--exclude",
                        ".git",
                        "--exclude",
                        "node_modules",
                        "--no-ignore",
                        "--ignore-file",
                        ".teleignore",
                        "--strip-cwd-prefix",
                    },
                    sort_lastused = true,
                },
                buffers = {
                    sort_lastused = true,
                    ignore_current_buffer = true,
                },
            },
        })


        -- load extension
        telescope.load_extension("fzf")

        -- set keymaps
        vim.keymap.set("n", "<leader>n", builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file" })
        vim.keymap.set("n", "<leader>fF", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set(
            "n",
            "<leader>fs",
            builtin.grep_string,
            { desc = "Search string in working directory" }
        )
        vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Git file" })
        vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Mark" })
        vim.keymap.set("n", "<leader>fR", builtin.registers, { desc = "Register" })
        vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume" })
        vim.keymap.set("n", "<leader>fh", builtin.oldfiles, { desc = "Oldfiles" })
        vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Command" })
        vim.keymap.set("n", "<leader>fS", builtin.search_history, { desc = "Search" })
        vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
        vim.keymap.set("n", "<leader>ft", builtin.tags, { desc = "Tags" })
        vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "Jumplist" })
        vim.keymap.set(
            "n",
            "<leader>fl",
            builtin.current_buffer_fuzzy_find,
            { desc = "Search word in current buffer" }
        )
    end
}
