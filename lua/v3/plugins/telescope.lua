return {
    "nvim-telescope/telescope.nvim",
        dependencies = { { "nvim-lua/plenary.nvim" } },
        config = function()
            -- Import necessary modules
            local telescope = require('telescope')

            -- Configure Telescope
            telescope.setup {
                defaults = {
                    prompt_prefix = '  ',
                    selection_caret = ' ❯ ',
                    --         entry_prefix = '  ',
                    --         layout_strategy = 'horizontal',
                    --         layout_config = {
                        --             vertical = { width = 100 },
                        --             bottom_pane = {
                            --                 prompt_position = "bottom",
                            --                 width = 1, 
                            --             },
                        --         },
                },
                pickers = {
                    find_files = {
                        find_command = {
                            'fd', '-t', 'f', '--hidden', '--exclude', '.git',
                            '--exclude', 'node_modules', '--no-ignore',
                            '--ignore-file', '.teleignore', '--strip-cwd-prefix',
                        },
                        sort_lastused = true,
                    },
                    buffers = {
                        sort_lastused = true,
                        ignore_current_buffer = true
                    },
                },
                --     extensions = {
                    --         fzf = {
                        --             fuzzy = true,
                        --             case_mode = 'smart_case',
                        --         },
                    --         file_browser = {
                        --             theme = 'ivy',
                        --             hijack_netrw = true,
                        --         },
                    --     },
            }

            vim.keymap.set('n', '<leader>n', '<Cmd>Telescope buffers<Cr>', { desc = "Find buffers" })
            vim.keymap.set('n', '<leader>ff', '<Cmd>Telescope find_files<Cr>', { desc = "Find file" })
            vim.keymap.set('n', '<leader>fF', '<Cmd>Telescope live_grep<Cr>', { desc = "Live grep" })
            vim.keymap.set('n', '<leader>fs', '<Cmd>Telescope grep_string<Cr>', { desc = "Search string in working directory" })
            vim.keymap.set('n', '<leader>fg', '<Cmd>Telescope git_files<Cr>', { desc = "Git file" })
            vim.keymap.set('n', '<leader>fm', '<Cmd>Telescope marks<Cr>', { desc = "Mark" })
            vim.keymap.set('n', '<leader>fR', '<Cmd>Telescope registers<Cr>', { desc = "Register" })
            vim.keymap.set('n', '<leader>fr', '<Cmd>Telescope resume<Cr>', { desc = "Resume" })
            vim.keymap.set('n', '<leader>fh', '<Cmd>Telescope oldfiles<Cr>', { desc = "Oldfiles" })
            vim.keymap.set('n', '<leader>fc', '<Cmd>Telescope command_history<Cr>', { desc = "Command" })
            vim.keymap.set('n', '<leader>fS', '<Cmd>Telescope search_history<Cr>', { desc = "Search" })
            vim.keymap.set('n', '<leader>fk', '<Cmd>Telescope keymaps<Cr>', { desc = "Keymaps" })
            vim.keymap.set('n', '<leader>ft', '<Cmd>Telescope tags<Cr>', { desc = "Tags" })
            vim.keymap.set('n', '<leader>fj', '<Cmd>Telescope jumplist<Cr>', { desc = "Tags" })
            vim.keymap.set('n', '<leader>fl', '<Cmd>Telescope current_buffer_fuzzy_find<Cr>', { desc = "Search word in current buffer" })
        end
}
