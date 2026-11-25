-- ============================================================================
-- Token / cost tracking helpers (module-level so keymaps can use them too)
-- ============================================================================

-- USD per 1M tokens + context window (tokens). Keys are matched as prefixes of
-- the active model name (longest wins), so dated model IDs still match.
-- Checked Nov 2026; re-verify against each provider's pricing page.
-- Note: Haiku 5.5 jumps to $0.50/$2.50 above 100k-token prompts (not modelled).
-- Only HTTP adapters are priced. Codex (ChatGPT login) and Kiro are ACP agents
-- billed through a subscription/credits, so they show tokens only.
local pricing = {
  -- Anthropic
  ["claude-haiku-5"] = { inp = 0.10, out = 0.50, ctx = 1000000 },
  ["claude-sonnet-5"] = { inp = 2.00, out = 10.00, ctx = 1000000 },
  ["claude-opus-5"] = { inp = 5.00, out = 25.00, ctx = 1000000 }, -- Opus 5
  ["claude-opus-5-5"] = { inp = 4.00, out = 20.00, ctx = 1000000 }, -- Opus 5.5
}
local default_ctx = 200000

local function fmt_k(n)
  return n >= 1000 and string.format("%.1fk", n / 1000) or tostring(n)
end

local function model_name(adapter)
  if not adapter then
    return nil
  end
  if type(adapter.model) == "table" and adapter.model.name then
    return adapter.model.name
  end
  local ok, m = pcall(function()
    return adapter.schema.model.default
  end)
  if ok and type(m) == "string" then
    return m
  end
  return nil
end

-- Longest-prefix match so "claude-opus-5-5" wins over "claude-opus-5".
local function find_pricing(name)
  if not name then
    return nil
  end
  local best, best_len = nil, 0
  for key, p in pairs(pricing) do
    if name:sub(1, #key) == key and #key > best_len then
      best, best_len = p, #key
    end
  end
  return best
end

-- Per-chat-buffer stats: settled cost + token bookkeeping.
--   last = context tokens at the end of the previous settled request
--   cur  = context tokens right now
--   cost = settled total (USD), turn = cost of the last finished request
local stats = {}

local function get_stats(bufnr)
  stats[bufnr] = stats[bufnr] or { last = 0, cur = 0, cost = 0, turn = 0 }
  return stats[bufnr]
end

-- The token_count callback can fire while another window is focused, so don't
-- blindly trust the current buffer.
local function chat_bufnr()
  local b = vim.api.nvim_get_current_buf()
  if vim.bo[b].filetype == "codecompanion" then
    return b
  end
  local ok, last = pcall(function()
    return require("codecompanion").last_chat()
  end)
  return (ok and last and last.bufnr) or b
end

-- Each turn resends the whole history: previous context is billed as input,
-- newly added tokens (the reply + your new message) are approximated as output.
-- Ignores prompt-cache discounts and hidden reasoning tokens, so treat as rough.
local function turn_cost(s, p, tokens)
  return (s.last * p.inp + math.max(tokens - s.last, 0) * p.out) / 1e6
end

-- Settle each finished request into the running total.
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestFinished",
  callback = function(args)
    local bufnr = args.data and args.data.bufnr
    local s = bufnr and stats[bufnr]
    if not (s and s.p and s.cur > s.last) then
      return
    end
    s.turn = turn_cost(s, s.p, s.cur)
    s.cost = s.cost + s.turn
    s.last = s.cur
  end,
})

-- Don't leak stats for closed chats.
vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    stats[args.buf] = nil
  end,
})

-- ============================================================================
-- Per-provider model router (uses the `ai-task-router` script on $PATH)
-- ============================================================================
-- Picks a model WITHIN the provider of the current chat, based on the message
-- being sent. Kiro is skipped: it already runs in auto mode.
--   anthropic (HTTP) -> router provider "claude"  (haiku / sonnet / opus)
--   codex     (ACP)  -> router provider "codex"   (ChatGPT login)
-- Routing only escalates within a chat (low -> medium -> high), never
-- downgrades, so prompt caching / agent context isn't thrown away.
-- Disable with `vim.g.ai_router_enabled = false` or <leader>aM.
--
-- Codex caveat: an ACP agent only accepts a model change once its session
-- exists, i.e. AFTER the first message. So the first message runs on Codex's
-- default model and routing starts from the second one.

local router_cmd = vim.g.ai_router_cmd or "ai-task-router"
local router_providers = { anthropic = "claude", codex = "codex" } -- adapter name -> router provider
local tier_rank = { low = 1, medium = 2, high = 3 }
local router_warned = false

-- Text of the message being written: everything after the last `## ` header.
local function last_user_text(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local start = 1
  for i = #lines, 1, -1 do
    if lines[i]:match("^##%s") then
      start = i + 1
      break
    end
  end
  return vim.trim(table.concat(lines, "\n", start))
end

-- Map the router's answer onto an ID the live Codex session actually offers.
-- codex-acp bridges differ: some advertise compound "<model>/<effort>" ids,
-- others bare model names, so try compound first, then bare.
local function pick_acp_model(chat, data)
  local conn = chat.acp_connection
  if not (conn and conn.session_id) then
    return nil -- session not up yet (first message)
  end
  local models = conn:get_models()
  local ids = {}
  for _, m in ipairs((models and models.availableModels) or {}) do
    local id = m.modelId or m.id
    if id then
      ids[#ids + 1] = id
    end
  end

  local wanted = {}
  if data.effort then
    wanted[#wanted + 1] = data.model .. "/" .. data.effort
  end
  wanted[#wanted + 1] = data.model
  for _, w in ipairs(wanted) do
    for _, id in ipairs(ids) do
      if id == w then
        return id
      end
    end
  end

  if not chat._router_warned then
    chat._router_warned = true
    vim.notify(
      string.format(
        "Router: Codex offers no model `%s`. Available: %s\nSet AI_ROUTER_CODEX_LOW/MEDIUM/HIGH to match.",
        wanted[1],
        #ids > 0 and table.concat(ids, ", ") or "(none reported)"
      ),
      vim.log.levels.WARN
    )
  end
  return nil
end

local function route_chat(chat)
  if vim.g.ai_router_enabled == false then
    return
  end
  local adapter = chat.adapter
  local provider = adapter and router_providers[adapter.name]
  if not provider then
    return
  end
  if vim.fn.executable(router_cmd) ~= 1 then
    if not router_warned then
      router_warned = true
      vim.notify("Router: `" .. router_cmd .. "` not on $PATH, model routing disabled", vim.log.levels.WARN)
    end
    return
  end

  local text = last_user_text(chat.bufnr)
  if text == "" then
    return
  end

  -- Task text goes over stdin so huge pasted prompts can't hit argv limits.
  local res = vim.system({ router_cmd, "--provider", provider, "--json" }, { stdin = text, text = true }):wait(1000)
  if res.code ~= 0 then
    return
  end
  local ok, data = pcall(vim.json.decode, res.stdout)
  if not ok or type(data) ~= "table" or not data.model then
    return
  end

  local rank = tier_rank[data.tier] or 2
  if rank <= (chat._router_rank or 0) then
    return
  end

  local target = data.model
  if adapter.type == "acp" then
    target = pick_acp_model(chat, data)
    if not target then
      return -- rank not consumed, so the next message retries
    end
  end
  chat._router_rank = rank

  if target ~= (chat._router_model or model_name(adapter)) then
    chat:change_model({ model = target })
    chat._router_model = target
    vim.notify(string.format("Router → %s (%s)", target, data.tier), vim.log.levels.INFO)
  end
end

-- ============================================================================
-- Kiro session resume (with preview)
-- ============================================================================
-- Lists Kiro's server-side sessions via `session/list`, builds a cheap preview
-- from the local session store, then calls `session/load` + `restore_session`
-- (the same path the built-in `/resume` uses) so Kiro gets its real context
-- back. The history extension's `gh` picker only restores the local transcript
-- into a NEW session, leaving Kiro without memory of the conversation.

local PREVIEW_LIMIT = 30 -- only build previews for the most recent N sessions

---Read a short head/tail preview for a session from the local store.
---Only reads the first 200 and last 20 lines, so big sessions stay cheap.
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

  -- Skip injected persona/rules/context blocks (the Akai prompts prepend a
  -- large hidden `# Persona ...` message); we want the first *real* prompt.
  local function is_boilerplate(content)
    return #content > 4000 or content:match("^%s*#%s*Persona") or content:match("^%s*<session_context>")
  end

  ---@return string? first_user, string? last_text
  local function scan(lines)
    local first_user, last_text
    for _, line in ipairs(lines) do
      local ok, msg = pcall(vim.json.decode, line)
      if ok and type(msg) == "table" and msg.payload then
        local t = msg.payload.type
        local content = msg.payload.content
        if type(content) == "string" and content ~= "" and not is_boilerplate(content) then
          if t == "user" and not first_user then
            first_user = content
          end
          if t == "user" or t == "assistant" then
            last_text = content
          end
        end
      end
    end
    return first_user, last_text
  end

  local first_user, head_last = scan(vim.fn.readfile(path, "", 200))
  local _, tail_last = scan(vim.fn.readfile(path, "", -20))
  local last_text = tail_last or head_last

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

local function resume_kiro_session()
  local cc = require("codecompanion")
  local utils = require("codecompanion.utils")

  local chat = cc.chat()
  if not chat then
    vim.notify("CodeCompanion: could not open a chat for resume", vim.log.levels.ERROR)
    return
  end

  -- Wait for the ACP connection to come up (poll, ~15s timeout).
  local tries = 0
  local timer = vim.uv.new_timer()
  local function stop_timer()
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end

  timer:start(
    100,
    150,
    vim.schedule_wrap(function()
      tries = tries + 1
      if not vim.api.nvim_buf_is_valid(chat.bufnr) then
        stop_timer() -- chat was closed while waiting
        return
      end

      local conn = chat.acp_connection
      if not (conn and conn:is_ready()) then
        if tries >= 100 then
          stop_timer()
          vim.notify(
            "CodeCompanion: Kiro ACP connection not ready after 15s. Check `kiro-cli whoami` / `kiro-cli login`.",
            vim.log.levels.ERROR
          )
        end
        return
      end
      stop_timer()

      if not (conn.can_list_sessions and conn:can_list_sessions() and conn:can_load_session()) then
        vim.notify("Kiro: this agent cannot list/load sessions", vim.log.levels.WARN)
        return
      end

      local sessions = conn:session_list({ max_sessions = 500 })
      if #sessions == 0 then
        vim.notify("Kiro: no previous sessions found", vim.log.levels.INFO)
        return
      end
      -- Most recent first (ISO timestamps sort lexicographically).
      table.sort(sessions, function(a, b)
        return (a.updatedAt or "") > (b.updatedAt or "")
      end)

      local choices, map = {}, {}
      for i, s in ipairs(sessions) do
        local when = ""
        if s.updatedAt then
          local ts = utils.timestamp_from_iso(s.updatedAt)
          if ts then
            when = "(" .. utils.make_relative(ts) .. ") "
          end
        end
        local label = when .. (s.title or s.sessionId)
        if i <= PREVIEW_LIMIT then
          local preview = disk_preview(s.sessionId)
          if preview ~= "" then
            label = label .. "  —  " .. preview
          end
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
        require("codecompanion.interactions.chat.acp.commands").link_buffer_to_session(chat.bufnr, conn.session_id)
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
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "echasnovski/mini.icons",
    "ravitemer/codecompanion-history.nvim",
  },
  cmd = { "CodeCompanionChat" },
  keys = {
    -- Start a fresh Kiro chat (Kiro is the default agent).
    { "<leader>ai", "<cmd>CodeCompanionChat adapter=kiro<cr>", mode = "n", desc = "AI Kiro chat" },
    -- Akai prompt with Claude via the Anthropic pay-as-you-go API.
    {
      "<leader>aC",
      function()
        require("codecompanion").prompt("akai-claude")
      end,
      mode = "n",
      desc = "AI Claude chat (Anthropic API)",
    },
    -- Akai prompt with ChatGPT through Codex (ChatGPT login, no API key).
    {
      "<leader>aG",
      function()
        require("codecompanion").prompt("akai-chatgpt")
      end,
      mode = "n",
      desc = "AI ChatGPT chat (Codex)",
    },
    -- Toggle the most recently opened chat, regardless of provider.
    { "<leader>aI", "<cmd>CodeCompanionChat toggle<cr>", mode = "n", desc = "AI Chat toggle" },
    { "<leader>ac", "<cmd>CodeCompanionChat add<cr>", mode = "v", desc = "AI Add to chat" },
    {
      "<leader>ac",
      "<cmd>%CodeCompanionChat add<cr>",
      mode = "n",
      desc = "AI Add to chat (file)",
    },
    {
      -- Turn automatic model routing on/off (Claude / ChatGPT chats only).
      "<leader>aM",
      function()
        vim.g.ai_router_enabled = vim.g.ai_router_enabled == false
        vim.notify("AI model router: " .. (vim.g.ai_router_enabled == false and "OFF" or "ON"), vim.log.levels.INFO)
      end,
      mode = "n",
      desc = "AI toggle model router",
    },
    {
      -- Token / cost stats on demand for the current (or last) chat.
      "<leader>at",
      function()
        local cc = require("codecompanion")
        local chat = cc.buf_get_chat(0) or cc.last_chat()
        local s = chat and stats[chat.bufnr]
        if not s then
          vim.notify("No token stats for this chat (HTTP adapters only)", vim.log.levels.INFO)
          return
        end
        local p = s.p
        local ctx = (p and p.ctx) or default_ctx
        local left = math.max(ctx - s.cur, 0)
        vim.notify(
          string.format(
            "Context: %s used / %s left\nLast reply: ~$%.4f\nChat total: ~$%.3f",
            fmt_k(s.cur),
            fmt_k(left),
            s.turn or 0,
            s.cost
          ),
          vim.log.levels.INFO
        )
      end,
      mode = "n",
      desc = "AI token/cost stats",
    },
    {
      "<leader>ar",
      resume_kiro_session,
      mode = "n",
      desc = "AI Resume Kiro session (with preview)",
    },
    {
      -- Kiro lists/loads sessions per cwd (session/list and session/load both
      -- send getcwd()). To resume a session from another project, cd there
      -- first, then run the normal resume picker.
      "<leader>aR",
      function()
        vim.ui.input({
          prompt = "Resume sessions from directory: ",
          default = vim.fn.getcwd(),
          completion = "dir",
        }, function(input)
          if not input or input == "" then
            return
          end
          local dir = vim.fn.expand(input)
          if vim.fn.isdirectory(dir) ~= 1 then
            vim.notify("Not a directory: " .. dir, vim.log.levels.ERROR)
            return
          end
          vim.cmd.cd(vim.fn.fnameescape(dir))
          vim.notify("cwd -> " .. dir, vim.log.levels.INFO)
          vim.schedule(resume_kiro_session)
        end)
      end,
      mode = "n",
      desc = "AI Resume Kiro session (pick directory)",
    },
    {
      -- Jump straight to a model picker for the active Kiro chat. The built-in
      -- `ga` keymap also switches models but goes through an adapter-selection
      -- step first; this skips to the model list. ACP only (Kiro, Codex):
      -- the connection reports its models once the session is established.
      -- For Claude (HTTP) chats use `ga`, or let the router pick.
      "<leader>am",
      function()
        local cc = require("codecompanion")
        local chat = cc.buf_get_chat(0) or cc.last_chat()
        if not chat then
          vim.notify("CodeCompanion: no active chat (open a chat first)", vim.log.levels.WARN)
          return
        end
        if chat.adapter.type ~= "acp" or not chat.acp_connection then
          vim.notify(
            "CodeCompanion: not an ACP (Kiro/Codex) chat. Use `ga` to change the model here.",
            vim.log.levels.WARN
          )
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

    -- Build a prompt-library entry that preloads the Akai core files + extra
    -- skill files as a hidden first message.
    --   skills   : extra files (relative to ~/ai) appended after core_files
    --   o.project: also append the project's .ai/ directory (if non-empty)
    --   o.extra  : function returning extra text to append (e.g. other dirs)
    --   o.opts   : extra prompt opts (alias, adapter, auto_submit, ...)
    --   o.prompts: override the default `{ { role = "user" } }`
    local function akai_prompt(description, skills, o)
      o = o or {}
      return {
        interaction = "chat",
        description = description,
        opts = vim.tbl_extend("force", {
          auto_submit = false,
          callbacks = {
            on_created = function(chat)
              local files = vim.deepcopy(core_files)
              vim.list_extend(files, skills)
              local content = load_ai_files(files)
              if o.project then
                local project_context = load_project_ai()
                if project_context ~= "" then
                  content = content .. "\n\n---\n\n" .. project_context
                end
              end
              if o.extra then
                local extra = o.extra()
                if extra ~= "" then
                  content = content .. "\n\n---\n\n" .. extra
                end
              end
              chat:add_message({ role = "user", content = content }, { visible = false, _meta = { sent = false } })
            end,
          },
        }, o.opts or {}),
        prompts = o.prompts or { { role = "user" } },
      }
    end

    local general_skills = { "skills/laravel-api.md", "skills/rails.md", "skills/debugging.md", "skills/devops.md" }
    local pr_skills = { "skills/laravel-api.md", "skills/code-review.md", "skills/pr-workflow.md" }

    require("codecompanion").setup({
      opts = {
        -- DEBUG is very chatty; flip it with `vim.g.ai_log_level = "DEBUG"`.
        log_level = vim.g.ai_log_level or "INFO",
      },

      adapters = {
        http = {
          -- Claude via Anthropic's pay-as-you-go API.
          -- Reads ANTHROPIC_API_KEY from the Neovim process environment.
          -- The model router escalates haiku -> sonnet -> opus per chat.
          -- (OpenAI HTTP adapter removed: ChatGPT goes through Codex below.)
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              schema = {
                model = { default = "claude-sonnet-5-5" },
              },
            })
          end,
        },

        -- Kiro remains available as your ACP agent and stays the default chat adapter.
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
              -- The v3 engine rejects a command-line --model flag, so the
              -- model is negotiated over the ACP session instead. "auto" lets
              -- kiro-cli pick a model per task server-side, so the router
              -- deliberately leaves Kiro alone.
              -- Run `kiro-cli chat --list-models` to see valid IDs.
              defaults = {
                session_config_options = {
                  model = "auto",
                },
              },
            })
          end,
          -- ChatGPT via your ChatGPT login (no OPENAI_API_KEY needed). Press `gd`
          -- or run /acp_session_options in a chat to see the model/effort IDs
          -- your Codex bridge offers; the router matches against that list.
          codex = function()
            return require("codecompanion.adapters").extend("codex", {
              defaults = {
                auth_method = "chat-gpt",
                session_config_options = {
                  mode = "read-only",
                },
              },
            })
          end,
        },
      },

      display = {
        chat = {
          window = {
            width = vim.g.ai_chat_width or 60,
          },
          auto_generate_title = false,
          show_token_count = true,
          -- Shows: "<used> used · <left> left (<pct>%) · reply ~$x · chat ~$y"
          -- Cost is shown only for models present in the `pricing` table
          -- (Anthropic). Kiro and Codex (ACP) are subscription/credit based,
          -- so they show tokens only.
          token_count = function(tokens, adapter)
            local p = find_pricing(model_name(adapter))
            local ctx = (p and p.ctx) or default_ctx
            local left = math.max(ctx - tokens, 0)
            local pct = math.floor(left / ctx * 100)
            local out = string.format(" %s used · %s left (%d%%)", fmt_k(tokens), fmt_k(left), pct)

            if p then
              local s = get_stats(chat_bufnr())
              s.p, s.cur = p, tokens
              -- Live estimate for the in-flight response + settled total.
              local live = turn_cost(s, p, tokens)
              out = out .. string.format(" · reply ~$%.4f · chat ~$%.3f", live, s.cost + live)
            end
            return out
          end,
        },
      },

      -- Use the modern `interactions` configuration. Kiro is the default chat
      -- agent; Claude / ChatGPT are opened separately through the Akai prompts.
      interactions = {
        chat = {
          -- Kiro is the default. <leader>aC opens a Claude API chat,
          -- <leader>aG opens a ChatGPT (Codex) chat.
          -- Inside a chat, ga can also be used to change the adapter/model.
          adapter = "kiro",

          -- Custom chat keymaps. Registered here (not via a FileType autocmd)
          -- so the entry shows up in the chat's `?` help alongside the
          -- built-ins. CodeCompanion resolves a function `callback` by calling
          -- it with the chat object (see utils/keymaps.lua resolve()).
          keymaps = {
            -- Same as the built-in send, but (1) warns instead of silently
            -- doing nothing when a previous request is still running (Chat:submit
            -- returns early on current_request with only a debug log), and
            -- (2) lets the model router pick the model for this message.
            send = {
              callback = function(chat)
                if chat.current_request then
                  vim.notify(
                    "CodeCompanion: previous request still running. <C-c> to stop it, then send again.",
                    vim.log.levels.WARN
                  )
                  return
                end
                vim.cmd("stopinsert")
                pcall(route_chat, chat) -- routing must never block sending
                chat:submit()
              end,
            },
            open_url_under_cursor = {
              modes = { n = "gb" },
              description = "Open URL under cursor in browser",
              callback = function()
                local url = vim.fn.expand("<cWORD>"):match("https?://[^%s<>\"'%)%]]+")
                if not url then
                  vim.notify("CodeCompanion: no URL under cursor", vim.log.levels.WARN)
                  return
                end
                url = url:gsub("[%.,;:!%?]+$", "") -- trailing punctuation isn't part of the URL
                vim.ui.open(url) -- Neovim 0.10+, picks the right opener per OS
              end,
            },
          },

          -- Ask for permission before Kiro performs actions through ACP.
          -- In the chat buffer, use g2 to approve once, g1 to always allow
          -- this action in this chat, g3 to reject, and g4 to cancel.
          -- Use gty to switch between Ask, Auto, and YOLO for this chat.
          tools = {
            opts = {
              approval_mode = "ask",
            },
          },
        },
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
        -- Claude (API key) and ChatGPT (Codex login) chats -------------------------------------------
        ["Akai Claude"] = akai_prompt("Chat with Akai persona using Claude API", general_skills, {
          project = true,
          opts = { alias = "akai-claude", adapter = { name = "anthropic" } },
        }),
        ["Akai ChatGPT"] = akai_prompt("Chat with Akai persona using ChatGPT (Codex)", general_skills, {
          project = true,
          opts = { alias = "akai-chatgpt", adapter = { name = "codex" } },
        }),

        -- Default-adapter (Kiro) prompts --------------------------------------
        ["Akai"] = akai_prompt("Chat with full Akai persona loaded", general_skills, { project = true }),
        ["Akai Laravel"] = akai_prompt(
          "Laravel API development with Akai",
          { "skills/laravel-api.md", "skills/keycloak.md", "skills/postgres.md", "workflows/laravel-api.md" },
          { project = true }
        ),
        ["Akai Rails"] = akai_prompt(
          "Legacy Rails work with Akai",
          { "skills/rails.md", "skills/postgres.md", "workflows/legacy-rails.md" },
          { project = true }
        ),
        ["Akai Neovim"] = akai_prompt("Neovim config help with Akai", { "skills/neovim.md" }),
        ["Akai Debug"] = akai_prompt("Debugging session with Akai", { "skills/debugging.md" }),
        ["Akai DevOps"] = akai_prompt("Docker, AWS, and deployment with Akai", { "skills/devops.md" }),
        ["Akai Docs"] = akai_prompt("Technical documentation with Akai", { "skills/documentation.md" }),
        ["Akai Refactor"] = akai_prompt(
          "Safe refactoring session with Akai",
          { "skills/refactor.md" },
          { project = true }
        ),
        ["Akai Postgres"] = akai_prompt("PostgreSQL queries and optimization with Akai", { "skills/postgres.md" }),
        ["Akai Playwright"] = akai_prompt("ATS Playwright automation with Akai", { "skills/playwright.md" }, {
          extra = function()
            local project_dir = vim.fn.expand("~/work/playwright/ats/.ai")
            if vim.fn.isdirectory(project_dir) == 1 then
              return load_dir_files(project_dir)
            end
            return ""
          end,
        }),
        ["Akai Bash"] = akai_prompt("Bash automation scripts with Akai", { "skills/bash.md" }),
        ["Akai Jira"] = akai_prompt("Generate Jira ticket from task description", { "skills/jira.md" }),
        ["Akai Review"] = akai_prompt("Code review with Akai", { "skills/code-review.md" }, {
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
        }),

        -- PR workflows ----------------------------------------------------------
        ["PR Check"] = akai_prompt("Validate branch for PR readiness", pr_skills, {
          project = true,
          opts = { auto_submit = true },
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
        }),
        ["PR Review"] = akai_prompt("Code review the current branch diff", pr_skills, {
          project = true,
          opts = { auto_submit = true },
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
        }),
        ["Project Refactor"] = {
          interaction = "chat",
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
                local instructions = "Refactor this file following project conventions"
                if vim.fn.filereadable(path) == 1 then
                  instructions = table.concat(vim.fn.readfile(path), "\n")
                end
                local filename = vim.api.nvim_buf_get_name(0)
                local filetype = vim.bo.filetype
                local source = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
                return instructions
                  .. "\n\nCurrent file: "
                  .. filename
                  .. "\n\n```"
                  .. filetype
                  .. "\n"
                  .. source
                  .. "\n```"
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
