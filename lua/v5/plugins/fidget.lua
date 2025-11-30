return {
  "j-hui/fidget.nvim",
  opts = {
    integration = {
      ["codecompanion"] = {
        enabled = true,
        -- Customize how CodeCompanion status is displayed
        -- Example: Show adapter, model, strategy, and exit status
        format = {
          pending = function(msg)
            return string.format("CodeCompanion: %s (thinking)", msg.adapter)
          end,
          done = function(msg)
            return string.format("CodeCompanion: %s (done)", msg.adapter)
          end,
          error = function(msg)
            return string.format("CodeCompanion: %s (error)", msg.adapter)
          end,
        },
      },
    },
  },
}
