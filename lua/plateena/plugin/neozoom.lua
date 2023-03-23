require("neo-zoom").setup {
    winopts = {
        offset = {
            -- : you can omit `top` and/or `left` to center the floating window.
            -- top = 0,
            -- left = 0.17,
            width = 180,
            height = 80,
        },
        -- : check :help nvim_open_win() for possible border values.
        border = "rounded",
    },
    exclude_filetypes = { "lspinfo", "mason", "lazy", "fzf", "qf" },
    exclude_buftypes = {},
    presets = { {
        filetypes = { "dapui_.*", "dap-repl" },
        config = {
            top = 0.25,
            left = 0.6,
            width = 180,
            height = 50,
        },
        callbacks = { function()
            vim.wo.wrap = true
        end },
    } },
    -- popup = {
    --   -- : Add popup-effect (replace the window on-zoom with a `[No Name]`).
    --   -- This way you won't see two windows of the same buffer
    --   -- got updated at the same time.
    --   enabled = true,
    --   exclude_filetypes = {},
    --   exclude_buftypes = {},
    -- },
}
vim.keymap.set(
    "n",
    "<A-z>",
    function()
        vim.cmd("NeoZoomToggle")
    end,
    {
        silent = true,
        nowait = true,
        desc = "Zoom current pane"
    }
)
