return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionInline", "CodeCompanionActions" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  opts = {
    log_level = "TRACE",

    adapters = {
      http = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            url = "http://localhost:11434/api/chat",
            headers = { ["Content-Type"] = "application/json" },
            parameters = {
              model = "qwen2.5-coder:7b",
              temperature = 0.1,
              stream = false, -- Use false for inline to avoid parsing issues
            },
            handlers = {
              setup = function(adapter)
                return adapter
              end,
              inline = function(data)
                if data and data.message and data.message.content then
                  return data.message.content
                end
                return nil
              end,
            },
          })
        end,
      },
    },

    strategies = {
      cmd = { adapter = "ollama", opts = { stream = true }, roles = { user = "zack" } },
      chat = { adapter = "ollama", opts = { stream = true }, roles = { user = "zack" } },
      inline = {
        adapter = "ollama",
        opts = { stream = false },
        keymaps = {
          accept_change = { modes = { n = "ga" }, description = "Accept suggested inline change" },
          reject_change = {
            modes = { n = "gr" },
            opts = { nowait = true },
            description = "Reject suggested inline change",
          },
        },
      },
    },

    presets = {
      inline_fix = {
        strategy = "inline",
        description = "Fix or rewrite selected code",
        prompts = { { role = "user", content = "{{input}}" } },
      },
      inline_generate = {
        strategy = "inline",
        description = "Generate new code based on instructions",
        prompts = { { role = "user", content = "{{input}}" } },
      },
    },

    actions = { edit_current_buffer = true },
  },
}
