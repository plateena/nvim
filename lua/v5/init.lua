-- load plugin manager (lazy.nvim)
require("v5.lazy")
-- Load LSP config AFTER lazy to ensure it's not managed by the plugin manager
require("v5.lsp")
