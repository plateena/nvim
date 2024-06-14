local lazy = require("lazy")

lazy.setup({
    { import = "v4/plugins" },
}, {
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
