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

  opts = {
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
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama",
            url = "http://localhost:11434/api/chat",
            headers = {
              ["Content-Type"] = "application/json",
            },
            parameters = {
              temperature = 0.1,
              top_p = 0.9,
              num_ctx = 8192,
            },
            schema = {
              model = { default = "qwen2.5-coder:3b" },
              temperature = { default = 0.1 },
              top_p = { default = 0.9 },
              num_ctx = { default = 8192 },
            },
            callbacks = {
              on_stdout = function(self, data)
                vim.notify("Ollama streaming: " .. vim.inspect(data), vim.log.levels.INFO)
              end,
            },
            handlers = {
              inline = function(data)
                vim.notify("Handler received: " .. type(data), vim.log.levels.DEBUG)

                -- Handle NDJSON streaming format from Ollama
                if type(data) == "string" then
                  local content = ""
                  for line in data:gmatch("[^\r\n]+") do
                    if line ~= "" then
                      local ok, json_data = pcall(vim.json.decode, line)
                      if ok and json_data.message and json_data.message.content then
                        content = content .. json_data.message.content
                      end
                    end
                  end
                  if content ~= "" then
                    vim.notify("Inline result: " .. content:sub(1, 50), vim.log.levels.INFO)
                    return content
                  end
                elseif data and data.message and data.message.content then
                  return data.message.content
                end
                return nil
              end,
            },
          })
        end,
        opts = {
          show_model_choices = true,
        },
      },
    },
    strategies = {
      cmd = {
        adapter = "ollama",
        roles = {
          user = "zack",
        },
      },
      chat = {
        adapter = "ollama",
        prompt_for_model = true,
        icons = {
          chat_context = "📎",
          buffer_pin = " ",
          buffer_watch = "👀 ",
        },
        fold_context = true,
        roles = {
          user = "zack",
        },
      },
      inline = {
        adapter = "ollama",
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
    prompt_library = require("v5.prompts"),
  },
}
