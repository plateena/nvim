local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

local setup = {
    plugins = {
        marks = true,         -- shows a list of your marks on ' and `
        registers = true,     -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
            enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 40, -- how many suggestions should be shown in the list?
        },
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
            operators = true,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = true,      -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true,      -- default bindings on <c-w>
            nav = true,          -- misc bindings to work with windows
            z = true,            -- bindings for folds, spelling and others prefixed with z
            g = true,            -- bindings for prefixed with g
        },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    -- operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+",      -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>",   -- binding to scroll up inside the popup
    },
    window = {
        border = "rounded",       -- none, single, double, shadow
        position = "bottom",      -- bottom, top
        margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
        padding = { 1, 1, 1, 1 }, -- extra window padding [top, right, bottom, left]
        winblend = 0,
    },
    layout = {
        height = { min = 6, max = 25 },                                           -- min and max height of the columns
        width = { min = 25, max = 50 },                                           -- min and max width of the columns
        spacing = 2,                                                              -- spacing between columns
        align = "left",                                                           -- align columns left, center or right
    },
    ignore_missing = false,                                                       -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true,                                                             -- show help message on the command line when the popup is visible
    triggers = "auto",                                                            -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_nowait = {
        -- marks
        "`",
        "'",
        "g`",
        "g'",
        -- registers
        '"',
        "<c-r>",
        -- spelling
        "z=",
    },
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for key maps that start with a native binding
        -- most people should not need to change this
        i = { "j", "k" },
        v = { "j", "k" },
    },
}

local opts = {
    mode = "n",     -- NORMAL mode
    prefix = "<leader>",
    buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true,  -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true,  -- use `nowait` when creating keymaps
}

local mappings = {
    ["q"] = { "<cmd>q!<CR>", "Quit" },
    ["<Cr>"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
    v = {
        name = "Vsnip",
        o = { "<cmd>VsnipOpenEdit<cr>", "Vsnip open edit" },
    },
    l = {
        name = "LSP - language server protocol",
    },
    f = {
        name = "Telescope",
    },
    g = {
        name = "Git",
        s = {"<cmd>Git<Cr>", "Git status"},
        l = {"<cmd>Git log<Cr>", "Git log"},
        v = {"<cmd>Gvdiffsplit<Cr>", "Git diff split"},
        ["p2"] = {"<cmd>diffput /2<Cr>", "Diffput 2"},
        ["p3"] = {"<cmd>diffput /3<Cr>", "Diffput 3"},
    },
    o = {
        name = "Options",
        f = {
            name = "Foldmethod",
            a = { "<Cmd>setlocal foldmethod='manual'<Cr>", "Set foldmethod manual" },
            e = { "<Cmd>setlocal foldmethod='expr'<Cr>", "Set foldmethod expr" },
            i = { "<Cmd>setlocal foldmethod='indent'<Cr>", "Set foldmethod indent" },
            m = { "<Cmd>setlocal foldmethod='marker'<Cr>", "Set foldmethod marker" },
            s = { "<Cmd>setlocal foldmethod='syntax'<Cr>", "Set foldmethod syntax" },
            d = { "<Cmd>setlocal foldmethod='diff'<Cr>", "Set foldmethod diff" },
        },
        y = {
            name = "Yank",
            i = { "<Cmd>setlocal paste<Cr>", "Set paste true" },
            o = { "<Cmd>setlocal nopaste<Cr>", "Set paste false" },
        },
        i = {
            name = "Yank",
            i = { "<Cmd>setlocal autoindent smartindent<Cr>", "Set autoindent and smartindent true" },
            o = { "<Cmd>setlocal noautoindent nosmartindent<Cr>", "Set autoindent and smartindent false" },
        },
        t = {
            name = "Tab",
            w = { "<Cmd>setlocal tabstop=2<Cr>", "Set tabstop 2" },
            r = { "<Cmd>setlocal tabstop=4<Cr>", "Set tabstop 4" },
        },
        s = {
            name = "Spell",
            q = { "<Cmd>setlocal spell<Cr>", "Set spell" },
            n = { "<Cmd>setlocal nospell<Cr>", "Set nospell" },
        },
        c = {
            name = "Conceal",
            q = { "<Cmd>setlocal conceallevel=0<Cr>", "Set conceallevel 0" },
            w = { "<Cmd>setlocal conceallevel=1<Cr>", "Set conceallevel 1" },
            e = { "<Cmd>setlocal conceallevel=2<Cr>", "Set conceallevel 2" },
            r = { "<Cmd>setlocal conceallevel=3<Cr>", "Set conceallevel 3" },
            a = { '<Cmd>setlocal concealcursor=""<Cr>', "Set concealcursor to null" },
        },
    },
}

which_key.setup(setup)
which_key.register(mappings, opts)
