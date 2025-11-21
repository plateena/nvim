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
      opts = {
        notification = {
          window = {
            winblend = 0,
            relative = "editor",
            align = "bottom",
          },
        },
      },
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
      log_level = "DEBUG",
      -- Send output to file for debugging
      send_output = function(msg)
        local log_file = vim.fn.stdpath("log") .. "/codecompanion.log"
        local f = io.open(log_file, "a")
        if f then
          f:write(os.date("%Y-%m-%d %H:%M:%S") .. " " .. vim.inspect(msg) .. "\n")
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
              model = "qwen2.5-coder:7b",
              temperature = 0.1,
              top_p = 0.9,
              num_ctx = 8192,
            },
            schema = {
              model = { default = "qwen2.5-coder:7b" },
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
        roles = {
          user = "zack",
        },
      },
      inline = {
        adapter = "ollama",
      },
    },
    display = {
      chat = {
        window = {
          layout = "vertical",
          width = 0.45,
          height = 0.8,
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
    prompt_library = {
      ["Code Review"] = {
        strategy = "chat",
        description = "Review the selected code",
        prompts = {
          {
            role = "system",
            content = "You are an expert code reviewer. Review the code for bugs, security issues, performance, and best practices.",
          },
          {
            role = "user",
            content = function(context)
              return "Please review this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Explain Code"] = {
        strategy = "chat",
        description = "Explain how the code works",
        prompts = {
          {
            role = "system",
            content = "You are an expert programmer. Explain code clearly and concisely.",
          },
          {
            role = "user",
            content = function(context)
              return "Explain this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
            end,
          },
        },
      },
      ["Generate Tests"] = {
        strategy = "chat",
        description = "Generate unit tests for the code",
        prompts = {
          {
            role = "system",
            content = "You are an expert at writing tests using TDD methodology. Generate comprehensive unit tests.",
          },
          {
            role = "user",
            content = function(context)
              return "Generate unit tests for this code:\n\n```"
                .. context.filetype
                .. "\n"
                .. context.selection
                .. "\n```"
            end,
          },
        },
      },
      ["Refactor"] = {
        strategy = "inline",
        description = "Refactor selected code",
        prompts = {
          {
            role = "system",
            content = "You are an expert programmer. Refactor code to improve readability, maintainability, and performance while preserving functionality.",
          },
          {
            role = "user",
            content = "Refactor this code",
          },
        },
      },
      ["Fix Bug"] = {
        strategy = "inline",
        description = "Fix bugs in selected code",
        prompts = {
          {
            role = "system",
            content = "You are an expert debugger. Fix bugs while maintaining code style and functionality.",
          },
          {
            role = "user",
            content = "Fix any bugs in this code",
          },
        },
      },
      ["Check Exist and Empty"] = {
        strategy = "inline",
        description = "Transform condition to check both existence and empty string",
        prompts = {
          {
            role = "system",
            content = "You are an expert programmer. Transform conditional checks to verify both existence and empty values. Return only the code, no explanations.",
          },
          {
            role = "user",
            content = "Transform this condition to check if the variable exists AND is not empty (handles null, undefined, and empty strings)",
          },
        },
      },
      ["Suggest Code"] = {
        strategy = "inline",
        description = "Suggest code completion after cursor",
        prompts = {
          {
            role = "system",
            content = function(context)
              return "You are an expert "
                .. context.filetype
                .. " programmer. Given the code context, suggest the most logical continuation of the code. Return only the code that should come next, no explanations or markdown. Match the existing code style and indentation."
            end,
          },
          {
            role = "user",
            content = function(context)
              local bufnr = context.bufnr
              local cursor = vim.api.nvim_win_get_cursor(0)
              local current_line = cursor[1]

              -- Get context: previous 20 lines and current line up to cursor
              local start_line = math.max(0, current_line - 20)
              local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, current_line, false)

              -- Get current line up to cursor position
              local current_line_text = vim.api.nvim_buf_get_lines(bufnr, current_line - 1, current_line, false)[1]
                or ""
              local before_cursor = current_line_text:sub(1, cursor[2])

              table.insert(lines, before_cursor)

              local code_context = table.concat(lines, "\n")

              return "Continue this code:\n\n```"
                .. context.filetype
                .. "\n"
                .. code_context
                .. "\n```\n\nProvide only the next logical code continuation."
            end,
          },
        },
      },
    },
    extension = {
      spinner = {
        enabled = true,
        opts = {
          style = "fidget",
          text = "Thinking...",
        },
      },
    },
  },
}
