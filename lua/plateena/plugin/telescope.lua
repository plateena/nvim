require('telescope').setup({
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
            i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                ["<C-h>"] = "which_key"
            }
        }
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
    },
    extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
    }
})

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
vim.keymap.set('n', '<leader>fk', '<Cmd>Telescope keymaps<Cr>', { desc = "Command" })
vim.keymap.set('n', '<leader>ft', '<Cmd>Telescope tags<Cr>', { desc = "Tags" })
vim.keymap.set('n', '<leader>fj', '<Cmd>Telescope jumplist<Cr>', { desc = "Tags" })
