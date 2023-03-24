local telescope = require("telescope")
-- require("telescope").load_extension("noice")

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
local telescopeConfig = require("telescope.config")
local previewers = require("telescope.previewers")
local Job = require("plenary.job")

local new_maker = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    Job:new({
        -- maybe we want to write something to the buffer here
        command = "file",
        args = { "--mime-type", "-b", filepath },
        on_exit = function(j)
            local mime_type = vim.split(j:result()[1], "/")[1]
            if mime_type == "text" then
                previewers.buffer_previewer_maker(filepath, bufnr, opts)
            else
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
                        "BINARY",
                    })
                end)
            end
        end,
    }):sync()
end

-- Clone the default Telescope configuration
local vimgrep_arguments =
{ table.unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")
-- You don't need to set any of these options.
-- IMPORTANT!: this is only a showcase of how you can set default options!
telescope.setup {
    defaults = {
        prompt_prefix = ' \u{e644} ',
        selection_caret = " ❯ ",
        entry_prefix = "   ",
        -- don't preview binary
        buffer_previewer_maker = new_maker,
        -- `hidden = true` is not supported in text grep commands.
        vimgrep_arguments = vimgrep_arguments,
        layout_config = {
            vertical = { width = 1 },
            -- other layout configuration here
        },
        -- other defaults configuration here
    },
    pickers = {
        find_files = {
            find_command = {
                "fd",
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
        buffers = { sort_lastused = true },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
                -- even more opts
            }
            -- pseudo code / specification for writing custom displays, like the one
            -- for "codeactions"
            -- specific_opts = {
            --   [kind] = {
            --     make_indexed = function(items) -> indexed_items, width,
            --     make_displayer = function(widths) -> displayer
            --     make_display = function(displayer) -> function(e)
            --     make_ordinal = function(e) -> string
            --   },
            --   -- for example to disable the custom builtin "codeactions" display
            --      do the following
            --   codeactions = false,
            -- }
        },
        file_browser = {
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            -- mappings = {
            --     ["i"] = {
            --         -- your custom insert mode mappings
            --     },
            --     ["n"] = {
            --         -- your custom normal mode mappings
            --     },
            -- },
        },
    },
}
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
-- require("telescope").load_extension "file_browser"

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
