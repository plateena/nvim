local lang =
{
    "bash",
    "css",
    "fish",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "php",
    "python",
    "regex",
    "scss",
    "tsx",
    "typescript",
    "vim",
    "yaml",
}

require("nvim-treesitter.configs").setup({
    -- change default mapping
    -- disable default mapping
    ensure_installed = lang,
    highlight = {
        enable = true,
    },
    autopairs = { enable = true },
    indent = {
        enable = true,
    },
    context_commentstring = {
        enable = true,
        commentary_integration = {
            Commentary = "g/",
            CommentaryLine = false,
        },
    },
})

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.api.nvim_create_autocmd(
    { "BufEnter" },
    {
        pattern = { "*" },
        command = "normal zx",
    }
)
