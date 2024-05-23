-- Load which-key only if available
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

-- Which-key setup
local setup = {
    plugins = {
        -- Which-key plugins configurations
        marks = true,
        registers = true,
        spelling = {
            enabled = true,
            suggestions = 40,
        },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
        },
    },
    key_labels = {
        -- Customize labels for certain keys
        breadcrumb = "»",
        separator = "➜",
        group = "+",
    },
    popup_mappings = {
        -- Mappings for popup navigation
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
    },
    window = {
        -- Popup window configurations
        border = "rounded",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 1, 1, 1, 1 },
        winblend = 0,
    },
    layout = {
        -- Popup layout configurations
        height = { min = 6, max = 25 },
        width = { min = 25, max = 50 },
        spacing = 2,
        align = "left",
    },
    ignore_missing = false, -- Show mappings even if not explicitly defined
    hidden = { -- Hide certain boilerplate mappings
        "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ ",
    },
    show_help = true, -- Show help message on the command line when the popup is visible
    triggers = "auto", -- Automatically set up triggers
    triggers_nowait = { -- Immediate triggers
        "`", "'", "g`", "g'", '"', "<c-r>", "z=",
    },
    triggers_blacklist = { -- List of mode / prefixes that should never be hooked by WhichKey
        i = { "j", "k" },
        v = { "j", "k" },
    },
}

-- General options for key mappings
local opts = {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
}

-- Key mappings
local mappings = {
    ["q"] = { "<cmd>q!<CR>", "Quit" },
    ["<Cr>"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
    v = {
        name = "Vsnip",
        o = { "<cmd>VsnipOpenEdit<cr>", "Vsnip open edit" },
    },
    l = { name = "LSP - language server protocol" },
    f = { name = "Telescope" },
    g = {
        name = "Git",
        s = { "<cmd>Git<Cr>", "Git status" },
        l = { "<cmd>Git log<Cr>", "Git log" },
        v = { "<cmd>Gvdiffsplit<Cr>", "Git diff split" },
        ["p2"] = { "<cmd>diffput /2<Cr>", "Diffput 2" },
        ["p3"] = { "<cmd>diffput /3<Cr>", "Diffput 3" },
    },
    m = {
        name = "Formatting"
    },
    o = { name = "Options" },
}

-- Define options related to specific sections
local options_mappings = {
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
}

-- Combine all mappings
local all_mappings = vim.tbl_extend("force", mappings, { o = { name = "Options",  options_mappings } })


-- Register which-key mappings
which_key.setup(setup)
which_key.register(all_mappings, opts)
