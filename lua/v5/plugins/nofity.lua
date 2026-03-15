return {
  "rcarriga/nvim-notify",
  enabled = false,
  config = function()
    notify = require("notify")

    notify.setup({
      top_down = false,
      stages = "slide",
    })
  end,
}
