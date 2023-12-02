-- Import necessary modules
local actions = require('telescope.actions')
local telescope = require('telescope')

-- Load Telescope extensions
require('telescope').load_extension('fzf')

-- Define custom key mappings
local mappings = {
    fn = '<Cmd>Telescope buffers<CR>',
    ff = '<Cmd>Telescope find_files<CR>',
    fl = '<Cmd>Telescope live_grep<CR>',
    fs = '<Cmd>Telescope grep_string<CR>',
    fg = '<Cmd>Telescope git_files<CR>',
    fm = '<Cmd>Telescope marks<CR>',
    ft = '<Cmd>Telescope registers<CR>',
    fr = '<Cmd>Telescope resume<CR>',
    fh = '<Cmd>Telescope oldfiles<CR>',
    fc = '<Cmd>Telescope command_history<CR>',
    fy = '<Cmd>Telescope search_history<CR>',
    fk = '<Cmd>Telescope keymaps<CR>',
    fa = '<Cmd>Telescope tags<CR>',
    fj = '<Cmd>Telescope jumplist<CR>',
    fz = '<Cmd>Telescope current_buffer_fuzzy_find<CR>',
}

-- Configure Telescope
telescope.setup {
    defaults = {
        prompt_prefix = '  ',
        selection_caret = ' ❯ ',
        entry_prefix = '  ',
        buffer_previewer_maker = new_maker,
        vimgrep_arguments = vimgrep_arguments,
        layout_strategy = 'horizontal',
        layout_config = {
            vertical = { width = 100 },
            bottom_pane = {
                prompt_position = "bottom",
                width = 1, 
            },
        },
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
        buffers = { sort_lastused = true },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            case_mode = 'smart_case',
        },
        file_browser = {
            theme = 'ivy',
            hijack_netrw = true,
        },
    },
}

-- Set key mappings
for mode, keymap in pairs(mappings) do
    vim.keymap.set('n', '<leader>' .. mode, keymap, { desc = 'Telescope ' .. mode:gsub("_", " ") })
end
