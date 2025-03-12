local lazy = require("lazy")

lazy.setup({
    spec = {
        { import = "v5/plugins" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
