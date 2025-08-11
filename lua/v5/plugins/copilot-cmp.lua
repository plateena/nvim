-- plugins/copilot-cmp.lua
return {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    ft = { 'php', 'javascript', 'ruby', 'typescript', 'lua' },
    config = function()
        require("copilot_cmp").setup()
    end,
}
