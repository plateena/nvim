return {
  "rcarriga/nvim-notify",
  config = function()
    notify = require("notify")

    notify.setup({
      top_down = false,
      stages = "slide",
    })
  end
}
