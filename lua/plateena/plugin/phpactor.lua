require("phpactor").setup({
    on_attach = on_attach,
    init_options = {
        ["language_server_phpstan.enabled"] = false,
        ["language_server_psalm.enabled"] = false,
    },
    install = {
        path = vim.fn.stdpath("data") .. "/lsp_servers/",
        branch = "master",
        bin = vim.fn.stdpath("data") .. "/lsp_servers/phpactor/bin/phpactor",
        php_bin = "php",
        composer_bin = "composer",
        git_bin = "git",
        check_on_startup = "none",
    },
    lspconfig = {
        enabled = true,
        options = {},
    },
})
