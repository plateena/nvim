return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  dependencies = {
    "ravitemer/mcphub.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "j-hui/fidget.nvim",
      opts = {},
    },
  },
  config = function(_, opts)
    require("codecompanion").setup(opts)
    -- Setup inline command
    vim.api.nvim_create_user_command("CodeCompanionInline", function(args)
      require("codecompanion").inline(args.args)
    end, { nargs = "*", range = true })
    -- Debug command to check last request
    vim.api.nvim_create_user_command("CodeCompanionDebug", function()
      local log_file = vim.fn.stdpath("log") .. "/codecompanion.log"
      vim.cmd("edit " .. log_file)
    end, {})
  end,
  opts = function()
    return {
      opts = {
        log_level = "INFO",
        -- Send output to file for debugging
        send_output = function(msg)
          local log_file = vim.fn.stdpath("log") .. "/codecompanion.log"
          local f = io.open(log_file, "a")
          if f then
            f:write(os.date("%Y-%m-%d %H:%M:%S") .. " [my custom debugger] " .. vim.inspect(msg) .. "\n")
            f:close()
          end
        end,
      },
      adapters = {
        http = {
          -- Load adapters as functions to delay execution
          starcoder_1b = function()
            return require("v5.codecompanion.adapters.starcoder_1b")
          end,
          qwen2_3b = function()
            return require("v5.codecompanion.adapters.qwen2_3b")
          end,
          opts = {
            show_model_choices = false,
          },
        },
      },
      strategies = {
        cmd = {
          adapter = "qwen2_3b",
          roles = {
            user = "zack",
          },
        },
        chat = {
          adapter = "qwen2_3b",
          prompt_for_model = true,
          icons = {
            chat_context = "📎",
            buffer_pin = " ",
            buffer_watch = "👀 ",
          },
          fold_context = true,
          roles = {
            user = "zack",
          },
        },
        inline = {
          adapter = "qwen2_3b",
          keymaps = {
            accept_change = {
              modes = { n = "ga" }, -- Remember this as DiffAccept
            },
            reject_change = {
              modes = { n = "gr" }, -- Remember this as DiffReject
            },
            always_accept = {
              modes = { n = "gy" }, -- Remember this as DiffYolo
            },
          },
        },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.3,
            position = "right",
          },
          show_settings = true,
          show_token_count = true,
        },
        inline = {
          diff = {
            enabled = true,
            close_chat_at = 240,
          },
        },
        action_palette = {
          width = 95,
          height = 10,
        },
      },
      prompt_library = require("v5.codecompanion.prompts"),
    }
  end,
}
