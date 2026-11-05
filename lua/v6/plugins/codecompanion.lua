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
    {
      "<leader>ac",
      "<cmd>%CodeCompanionChat add<cr>",
      mode = "n",
      desc = "AI Add to chat (file)",
    },
    {
      "<leader>af",
      "<cmd>%CodeCompanion /fix<cr>",
      mode = "n",
      desc = "AI Fix code (file)",
    },
    {
      "<leader>ae",
      "<cmd>%CodeCompanion /explain<cr>",
      mode = "n",
      desc = "AI Explain (file)",
    },
    {
      "<leader>at",
      "<cmd>%CodeCompanion /unit_tests<cr>",
      mode = "n",
      desc = "AI Generate tests (file)",
    },
    {
      -- Proper Kiro resume with a PREVIEW of each session.
      --
      -- Opens a FRESH chat, lists Kiro's server-side sessions via `session/list`,
      -- and for each one reads a cheap head/tail preview straight from the local
      -- session store (~/.kiro/sessions/<bucket>/<sessionId>/messages.jsonl) so
      -- you can tell sessions apart before loading. On selection it calls
      -- `session/load` + `restore_session` -- the same path the built-in
      -- `/resume` uses -- so Kiro gets its real conversation context back.
      --
      -- This is different from the history extension's `gh` picker, which only
      -- restores the local transcript into a NEW session and leaves Kiro with
      -- no memory of the prior conversation.
      "<leader>ar",
      function()
        local cc = require("codecompanion")
        local utils = require("codecompanion.utils")

        ---Read a short head/tail preview for a session from the local store.
        ---Returns "head … tail" built from the first user prompt and last message.
        ---@param session_id string
        ---@return string
        local function disk_preview(session_id)
          local base = vim.fn.expand("~/.kiro/sessions")
          -- messages.jsonl lives under an opaque bucket dir, so glob for it.
          local hits = vim.fn.glob(base .. "/*/" .. session_id .. "/messages.jsonl", false, true)
          local path = hits and hits[1]
          if not path or vim.fn.filereadable(path) ~= 1 then
            return ""
          end

          local function clean(s)
            s = tostring(s or ""):gsub("%s+", " ")
            s = s:gsub("^%s+", "")
            return s
          end

          local first_user, last_text
          for _, line in ipairs(vim.fn.readfile(path)) do
            local ok, msg = pcall(vim.json.decode, line)
            if ok and type(msg) == "table" and msg.payload then
              local t = msg.payload.type
              local content = msg.payload.content
              if type(content) == "string" and content ~= "" then
                if t == "user" and not first_user then
                  -- Skip injected persona/rules/context blocks (the Akai prompts
                  -- prepend a large hidden `# Persona ...` message); we want the
                  -- first *real* prompt. Heuristic: skip very large messages and
                  -- known boilerplate headers.
                  local is_boilerplate = #content > 4000
                    or content:match("^%s*#%s*Persona")
                    or content:match("^%s*<session_context>")
                  if not is_boilerplate then
                    first_user = content
                  end
                end
                if t == "user" or t == "assistant" then
                  local is_boilerplate = #content > 4000
                    or content:match("^%s*#%s*Persona")
                    or content:match("^%s*<session_context>")
                  if not is_boilerplate then
                    last_text = content
                  end
                end
              end
            end
          end

          local head = clean(first_user):sub(1, 60)
          local tail = clean(last_text):sub(1, 60)
          if head == "" and tail == "" then
            return ""
          end
          if head ~= "" and tail ~= "" and head ~= tail then
            return head .. "  …  " .. tail
          end
          return head ~= "" and head or tail
        end

        local chat = cc.chat()
        if not chat then
          vim.notify("CodeCompanion: could not open a chat for resume", vim.log.levels.ERROR)
          return
        end

        local tries = 0
        local timer = vim.uv.new_timer()
        timer:start(
          100,
          150,
          vim.schedule_wrap(function()
            tries = tries + 1
            local conn = chat.acp_connection
            local ready = conn and conn:is_ready()
            if not ready then
              if tries >= 40 then -- ~6s timeout
                timer:stop()
                timer:close()
                vim.notify("CodeCompanion: Kiro ACP connection not ready", vim.log.levels.WARN)
              end
              return
            end
            timer:stop()
            timer:close()

            if not (conn.can_list_sessions and conn:can_list_sessions() and conn:can_load_session()) then
              vim.notify("Kiro: this agent cannot list/load sessions", vim.log.levels.WARN)
              return
            end

            local sessions = conn:session_list({ max_sessions = 500 })
            if #sessions == 0 then
              vim.notify("Kiro: no previous sessions found", vim.log.levels.INFO)
              return
            end

            local choices, map = {}, {}
            for i, s in ipairs(sessions) do
              local when = ""
              if s.updatedAt then
                local ts = utils.timestamp_from_iso(s.updatedAt)
                if ts then
                  when = "(" .. utils.make_relative(ts) .. ") "
                end
              end
              local title = s.title or s.sessionId
              local preview = disk_preview(s.sessionId)
              local label = when .. title
              if preview ~= "" then
                label = label .. "  —  " .. preview
              end
              choices[i] = label
              map[i] = s
            end

            vim.ui.select(choices, { prompt = "Resume Kiro Session", kind = "codecompanion.nvim" }, function(_, idx)
              if not idx then
                return
              end
              local selected = map[idx]
              local updates = {}
              local ok = conn:load_session(selected.sessionId, {
                on_session_update = function(u)
                  table.insert(updates, u)
                end,
              })
              if not ok then
                vim.notify("Kiro: failed to load session", vim.log.levels.ERROR)
                return
              end
              require("codecompanion.interactions.chat.acp.commands").link_buffer_to_session(
                chat.bufnr,
                conn.session_id
              )
              require("codecompanion.interactions.chat.acp.render").restore_session(chat, updates)
              if selected.title then
                chat:set_title(selected.title)
              end
              utils.fire("ACPChatRestored", {
                bufnr = chat.bufnr,
                id = chat.id,
                session_id = conn.session_id,
                title = chat.title,
              })
              vim.notify("Kiro: resumed " .. (selected.title or selected.sessionId), vim.log.levels.INFO)
            end)
          end)
        )
      end,
      mode = "n",
      desc = "AI Resume Kiro session (with preview)",
    },
    {
      -- Jump straight to a model picker for the active Kiro chat. The built-in
      -- `ga` keymap also switches models but goes through an adapter-selection
      -- step first; this skips to the model list.
      --
      -- Implementation notes / why the earlier version failed:
      --   * Resolve the chat from the CURRENT buffer first and only fall back
      --     to last_chat(); last_chat() returns the most recently *created*
      --     chat, which may be stale or nil.
      --   * Reuse CodeCompanion's own `adapters.ui.select_model` + the
      --     `chat.acp_connection:get_models()` data, i.e. the exact path the
      --     built-in `ga` keymap uses. This avoids a hand-rolled picker that
      --     can silently mismatch the model list shape. Picking a model calls
      --     `chat:change_model()` -> session/set_config_option over ACP.
      --   * The ACP connection only knows the models AFTER the session is
      --     established, so guard on `acp_connection` + session_id being ready.
      "<leader>am",
      function()
        local cc = require("codecompanion")
        local chat = cc.buf_get_chat(0) or cc.last_chat()
        if not chat then
          vim.notify("CodeCompanion: no active chat (open a chat first)", vim.log.levels.WARN)
          return
        end
        if chat.adapter.type ~= "acp" or not chat.acp_connection then
          vim.notify("CodeCompanion: active chat is not an ACP session", vim.log.levels.WARN)
          return
        end
        if not chat.acp_connection.session_id then
          vim.notify("CodeCompanion: Kiro session not ready yet — send one message first", vim.log.levels.WARN)
          return
        end

        local models = chat.acp_connection:get_models()
        if not models or not models.availableModels or #models.availableModels == 0 then
          vim.notify("CodeCompanion: Kiro did not report any models", vim.log.levels.WARN)
          return
        end

        require("codecompanion.adapters.ui").select_model({
          adapter = chat.adapter,
          acp_models = models,
          on_choice = function(model_id)
            if not model_id then
              return
            end
            chat:change_model({ model = model_id })
            vim.notify("Kiro model → " .. model_id, vim.log.levels.INFO)
          end,
        })
      end,
      mode = "n",
      desc = "AI Select Kiro model",
    },
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
      if vim.fn.isdirectory(expanded) ~= 1 then
        return ""
      end
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
      adapters = {
        acp = {
          -- Kiro v3 engine. The built-in adapter runs `kiro-cli acp` which
          -- defaults to the v2 engine; override the command to select v3.
          -- --auth-method cli reuses the `kiro-cli login` session (also the
          -- CLI default, set explicitly to be robust against default changes).
          kiro = function()
            return require("codecompanion.adapters").extend("kiro", {
              commands = {
                default = {
                  "kiro-cli",
                  "acp",
                  "--agent-engine",
                  "v3",
                  "--auth-method",
                  "cli",
                },
              },
              -- Model selection. The v3 engine rejects a command-line --model
              -- flag, so the model is negotiated over the ACP session instead.
              -- CodeCompanion forwards defaults.session_config_options.model
              -- to `session/set_model`. "auto" lets kiro-cli pick a model per
              -- task on the server rather than pinning a single one.
              -- Run `kiro-cli chat --list-models` to see valid IDs.
              defaults = {
                session_config_options = {
                  model = "auto",
                },
              },
            })
          end,
        },
        ollama_local = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama_local",
            schema = {
              model = { default = "qwen2.5-coder:14b" },
              num_ctx = { default = 16384 },
            },
          })
        end,
      },

      display = {
        chat = {
          window = {
            width = vim.g.ai_chat_width or 60,
          },
          auto_generate_title = false,
          show_token_count = true,
          token_count = function(tokens, adapter)
            return " (" .. tokens .. " tokens)"
          end,
        },
      },

      -- NOTE: this uses the modern `interactions` key (not the legacy
      -- `strategies` key). CodeCompanion's setup merges a `strategies` table
      -- OVER the top-level `interactions` table, so having both present would
      -- silently discard whatever we put in `interactions` (that is why an
      -- earlier `approval_mode` override had no effect). Keeping everything
      -- under `interactions` avoids that trap.
      interactions = {
        chat = {
          adapter = "kiro",

          -- Custom chat keymaps. Registered here (not via a FileType autocmd)
          -- so the entry shows up in the chat's `?` help alongside the
          -- built-ins. CodeCompanion resolves a function `callback` by calling
          -- it with the chat object (see utils/keymaps.lua resolve()).
          keymaps = {
            open_url_under_cursor = {
              modes = { n = "gb" },
              description = "Open URL under cursor in browser",
              callback = function()
                local url = vim.fn.expand("<cWORD>")
                local match = url:match("https?://[%w-_%.%?%.:/%+=&#@!$'%(%)%*,;~]+")
                if not match then
                  vim.notify("CodeCompanion: no URL under cursor", vim.log.levels.WARN)
                  return
                end
                vim.fn.system({ "google-chrome", match })
              end,
            },
          },

          -- Tool-call approval behaviour.
          --
          -- Kiro's v3 engine routes file edits (str_replace / write / append)
          -- through an ACP permission request whose `toolCall.kind` is NULL.
          -- CodeCompanion's "auto" mode only auto-approves recognised kinds
          -- (edit/read/fetch/search), so a null-kind edit is NOT auto-approved
          -- and falls through to an interactive prompt -- which blocks the
          -- whole turn until answered. That is the hang we kept hitting:
          -- reads/searches went through, but every edit stalled. Verified by
          -- probing the live ACP server: edit permissions arrive as
          -- `kind=None` ("Write File" / "Append to File"), while still
          -- offering an `allow_once` option.
          --
          -- "yolo" approves every tool call unconditionally (checked before
          -- any kind lookup), so null-kind edits no longer stall. This is a
          -- trusted local Kiro CLI, so that trade-off is fine. Use `gty` in a
          -- chat to dial back to "ask" when you want to review each action.
          tools = {
            opts = {
              approval_mode = "yolo",
            },
          },
        },
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
                local files = vim.deepcopy(core_files)
                vim.list_extend(
                  files,
                  { "skills/laravel-api.md", "skills/rails.md", "skills/debugging.md", "skills/devops.md" }
                )
                local content = load_ai_files(files)
                local project_context = load_project_ai()
                if project_context ~= "" then
                  content = content .. "\n\n---\n\n" .. project_context
                end
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
                vim.list_extend(
                  files,
                  { "skills/laravel-api.md", "skills/keycloak.md", "skills/postgres.md", "workflows/laravel-api.md" }
                )
                local content = load_ai_files(files)
                local project_context = load_project_ai()
                if project_context ~= "" then
                  content = content .. "\n\n---\n\n" .. project_context
                end
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
                vim.list_extend(files, { "skills/rails.md", "skills/postgres.md", "workflows/legacy-rails.md" })
                local content = load_ai_files(files)
                local project_context = load_project_ai()
                if project_context ~= "" then
                  content = content .. "\n\n---\n\n" .. project_context
                end
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
        ["Akai DevOps"] = {
          interaction = "chat",
          description = "Docker, AWS, and deployment with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/devops.md" })
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
        ["Akai Docs"] = {
          interaction = "chat",
          description = "Technical documentation with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/documentation.md" })
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
        ["Akai Refactor"] = {
          interaction = "chat",
          description = "Safe refactoring session with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/refactor.md" })
                local content = load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
              end,
            },
          },
          prompts = {
            { role = "user" },
          },
        },
        ["Akai Postgres"] = {
          interaction = "chat",
          description = "PostgreSQL queries and optimization with Akai",
          opts = {
            auto_submit = false,
            callbacks = {
              on_created = function(chat)
                local files = vim.deepcopy(core_files)
                vim.list_extend(files, { "skills/postgres.md" })
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
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
                  return "Review this code:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. table.concat(context.lines, "\n")
                    .. "\n```"
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
                vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md", "skills/pr-workflow.md" })
                local content = load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
                return "Run PR validation against origin/develop"
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
                vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md", "skills/pr-workflow.md" })
                local content = load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
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
                return "Review this PR's diff against origin/develop as the reviewer (someone else's code). Give feedback, do not modify files."
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
