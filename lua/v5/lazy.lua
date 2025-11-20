local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local lazy = require("lazy")

lazy.setup({
    spec = {
        { "folke/lazy.nvim", version = "*" },
        { import = "v5.plugins" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})

-- Load LSP config AFTER lazy to ensure it's not managed by the plugin manager
require("v5.lsp")
-- require("v5.lsp-debug")
