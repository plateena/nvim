return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "echasnovski/mini.icons",
    "ravitemer/codecompanion-history.nvim",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>ai", "<cmd>CodeCompanionChat toggle<cr>", mode = { "n", "v" }, desc = "AI Chat toggle" },
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
    { "<leader>ac", "<cmd>CodeCompanionChat add<cr>", mode = "v", desc = "AI Add to chat" },
    { "<leader>af", "<cmd>CodeCompanion /fix<cr>", mode = "v", desc = "AI Fix code" },
    { "<leader>ae", "<cmd>CodeCompanion /explain<cr>", mode = "v", desc = "AI Explain" },
    { "<leader>at", "<cmd>CodeCompanion /unit_tests<cr>", mode = "v", desc = "AI Generate tests" },
    { "<leader>ac", function() vim.cmd("normal! ggVG") vim.schedule(function() vim.cmd("'<,'>CodeCompanionChat add") end) end, mode = "n", desc = "AI Add to chat (file)" },
    { "<leader>af", function() vim.cmd("normal! ggVG") vim.schedule(function() vim.cmd("'<,'>CodeCompanion /fix") end) end, mode = "n", desc = "AI Fix code (file)" },
    { "<leader>ae", function() vim.cmd("normal! ggVG") vim.schedule(function() vim.cmd("'<,'>CodeCompanion /explain") end) end, mode = "n", desc = "AI Explain (file)" },
    { "<leader>at", function() vim.cmd("normal! ggVG") vim.schedule(function() vim.cmd("'<,'>CodeCompanion /unit_tests") end) end, mode = "n", desc = "AI Generate tests (file)" },
  },

  config = function()
    local global_ai_dir = vim.g.ai_global_dir or "~/ai"
    local project_ai_dir = vim.g.ai_project_dir or ".ai"

    local ai_dir = vim.fn.expand(global_ai_dir .. "/")
    local function load_ai_files(files)
      local parts = {}
      for _, f in ipairs(files) do
        local path = ai_dir .. f
        if vim.fn.filereadable(path) == 1 then
          table.insert(parts, table.concat(vim.fn.readfile(path), "\n"))
        else
          vim.notify("Akai: missing file " .. path, vim.log.levels.WARN)
        end
      end
      return table.concat(parts, "\n\n---\n\n")
    end

    local function load_dir_files(dir)
      local expanded = vim.fn.expand(dir)
      if vim.fn.isdirectory(expanded) ~= 1 then return "" end
      local files = vim.fn.glob(expanded .. "/*", false, true)
      local parts = {}
      for _, path in ipairs(files) do
        if vim.fn.filereadable(path) == 1 then
          table.insert(parts, table.concat(vim.fn.readfile(path), "\n"))
        end
      end
      return table.concat(parts, "\n\n---\n\n")
    end

    local function load_project_ai()
      return load_dir_files(vim.fn.getcwd() .. "/" .. project_ai_dir)
    end

    local core_files = { "persona.md", "taste.md", "rules.md", "context.md" }

    require("codecompanion").setup({
      display = {
        chat = {
          window = {
            width = vim.g.ai_chat_width or 60,
          },
          auto_generate_title = false,
        },
      },

      strategies = {
        chat = { adapter = "kiro" },
        inline = { adapter = "kiro" },
      },

      rules = {
        akai = {
          description = "Akai persona and core rules",
          files = {
            { path = global_ai_dir, files = "*.md" },
          },
        },
        project = {
          description = "Project-level AI context",
          files = {
            { path = project_ai_dir, files = "*" },
            "docker-compose.yml",
            "docker-compose.yaml",
            "Dockerfile",
          },
        },
        opts = {
          chat = {
            autoload = {},
            enabled = false,
          },
        },
      },

      prompt_library = {
        ["Akai"] = {
          interaction = "chat",
          description = "Chat with full Akai persona loaded",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                chat:add_message(
                  { role = "user", content = load_ai_files(core_files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Laravel"] = {
          interaction = "chat",
          description = "Laravel API development with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/laravel-api.md", "skills/keycloak.md", "workflows/laravel-api.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Rails"] = {
          interaction = "chat",
          description = "Legacy Rails work with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/rails.md", "workflows/legacy-rails.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Neovim"] = {
          interaction = "chat",
          description = "Neovim config help with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/neovim.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Debug"] = {
          interaction = "chat",
          description = "Debugging session with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/debugging.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Playwright"] = {
          interaction = "chat",
          description = "ATS Playwright automation with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/playwright.md" })
                local content = load_ai_files(files)
                local project_dir = vim.fn.expand("~/work/playwright/ats/.ai")
                if vim.fn.isdirectory(project_dir) == 1 then
                  content = content .. "\n\n---\n\n" .. load_dir_files(project_dir)
                end
                chat:add_message(
                  { role = "user", content = content },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Bash"] = {
          interaction = "chat",
          description = "Bash automation scripts with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/bash.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Jira"] = {
          interaction = "chat",
          description = "Generate Jira ticket from task description",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/jira.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Review"] = {
          interaction = "chat",
          description = "Code review with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/code-review.md" })
                chat:add_message(
                  { role = "user", content = load_ai_files(files) },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            {
              role = "user",
              content = function(context)
                if context.is_visual then
                  return "Review this code:\n\n```" .. context.filetype .. "\n" .. table.concat(context.lines, "\n") .. "\n```"
                end
              end,
            },
          },
        },
        ["PR Check"] = {
          interaction = "chat",
          description = "Validate branch for PR readiness",
          opts = {
            auto_submit = true,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md" })
                local content = load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                chat:add_message(
                  { role = "user", content = content },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            {
              role = "user",
              content = function()
                local path = vim.fn.getcwd() .. "/" .. project_ai_dir .. "/prompts/pr.md"
                if vim.fn.filereadable(path) == 1 then
                  return table.concat(vim.fn.readfile(path), "\n")
                end
                return "Run PR validation against develop-api"
              end,
            },
          },
        },
        ["PR Review"] = {
          interaction = "chat",
          description = "Code review the current branch diff",
          opts = {
            auto_submit = true,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md" })
                local content = load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                chat:add_message(
                  { role = "user", content = content },
                  { visible = false, _meta = { sent = false } }
                )
              end,
            },
          },
          prompts = {
            {
              role = "user",
              content = function()
                local path = vim.fn.getcwd() .. "/" .. project_ai_dir .. "/prompts/review.md"
                if vim.fn.filereadable(path) == 1 then
                  return table.concat(vim.fn.readfile(path), "\n")
                end
                return "Review the diff of this branch against develop-api"
              end,
            },
          },
        },
        ["Project Refactor"] = {
          interaction = "inline",
          description = "Refactor file following project conventions",
          opts = { auto_submit = true },
          prompts = {
            {
              role = "system",
              content = function()
                return load_project_ai()
              end,
            },
            {
              role = "user",
              content = function()
                local path = vim.fn.getcwd() .. "/" .. project_ai_dir .. "/prompts/refactor.md"
                if vim.fn.filereadable(path) == 1 then
                  return table.concat(vim.fn.readfile(path), "\n")
                end
                return "Refactor this file following project conventions"
              end,
            },
          },
        },
      },

      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            save_chat_keymap = "sc",
            auto_save = true,
            expiration_days = 0,
            picker = "snacks",
            auto_generate_title = false,
            continue_last_chat = false,
            delete_on_clearing_chat = false,
          },
        },
      },
    })
  end,
}
