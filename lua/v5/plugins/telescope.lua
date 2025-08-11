return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")
        local open_with_trouble = require("trouble.sources.telescope").open

        telescope.setup({
            defaults = {
                path_display = { shorten = { len = 3 } },
                prompt_prefix = "  ",
                selection_caret = " ❯ ",
                mappings = {
                    i = {
                        ["<C-k>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.move_selection_previous,
                        ["<C-n>"] = actions.move_selection_next,
                        ["<C-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        ["<C-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
                        ["<C-t>"] = open_with_trouble,
                    },
                    n = {},
                },
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

        local function grep_git_files()
            -- Check if we're in a git repository
            local git_files = vim.fn.systemlist('git ls-files 2>/dev/null')

            if vim.v.shell_error ~= 0 or #git_files == 0 then
                print("Not in a git repository or no tracked files found")
                return
            end

            builtin.live_grep({
                search_dirs = git_files,
                prompt_title = "Live Grep Git Files"
            })
        end

        local function grep_in_dir_picker()
            builtin.find_files({
                prompt_title = "Select Directory to Grep",
                find_command = { "find", ".", "-type", "d", "-not", "-path", "*/.*" },
                attach_mappings = function(prompt_bufnr, map)
                    local action_state = require('telescope.actions.state')

                    map('i', '<CR>', function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)

                        if selection then
                            builtin.live_grep({
                                search_dirs = { selection.path },
                                prompt_title = "Live Grep in " .. selection.value
                            })
                        end
                    end)

                    return true
                end,
            })
        end

        local function live_grep_quickfix()
            local qf_list = vim.fn.getqflist()
            local files = {}
            local seen = {}

            for _, item in ipairs(qf_list) do
                if item.bufnr > 0 then
                    local filename = vim.fn.bufname(item.bufnr)
                    if filename ~= "" and not seen[filename] then
                        table.insert(files, filename)
                        seen[filename] = true
                    end
                end
            end

            builtin.live_grep({
                search_dirs = files
            })
        end

        -- load extension
        telescope.load_extension("fzf")

        -- set keymaps
        vim.keymap.set("n", "<leader>n", builtin.buffers, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file" })
        vim.keymap.set("n", "<leader>fF", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>fG", grep_git_files, { desc = "Live grep git files" })
        vim.keymap.set("n", "<leader>fD", grep_in_dir_picker, { desc = "Live grep in dir" })
        vim.keymap.set("n", "<leader>fQ", live_grep_quickfix, { desc = "Live grep in quickfix" })
        vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Search string in working directory" })
        vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Git file" })
        vim.keymap.set("n", "<leader>fa", builtin.git_status, { desc = "Git status" })
        vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "Mark" })
        vim.keymap.set("n", "<leader>fR", builtin.registers, { desc = "Register" })
        vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume" })
        vim.keymap.set("n", "<leader>fh", builtin.oldfiles, { desc = "Oldfiles" })
        vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Command" })
        vim.keymap.set("n", "<leader>fS", builtin.search_history, { desc = "Search" })
        vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
        vim.keymap.set("n", "<leader>ft", builtin.tags, { desc = "Tags" })
        vim.keymap.set("n", "<leader>fj", builtin.jumplist, { desc = "Jumplist" })
        vim.keymap.set("n", "<leader>fl", builtin.current_buffer_fuzzy_find, { desc = "Search word in current buffer" })
    end,
}
