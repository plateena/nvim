return {
  -- Amazon Q inline completions (via LSP textDocument/completion → blink.cmp)
  {
    "awslabs/amazonq.nvim",
    opts = {
      ssoStartUrl = vim.g.ai_sso_url or "https://inscale.awsapps.com/start",
      inline_suggest = true,
    },
  },
  -- CodeCompanion for AI chat (uses Kiro CLI via ACP)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.icons",
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
      -- Read from global nvim config (set in config/options.lua)
      local global_ai_dir = vim.g.ai_global_dir or "~/ai"
      local project_ai_dir = vim.g.ai_project_dir or ".ai"

      -- Helper to read and concat AI prompt files
      local ai_dir = vim.fn.expand(global_ai_dir .. "/")
      local function load_ai_files(files)
        local parts = {}
        for _, f in ipairs(files) do
          local path = ai_dir .. f
          if vim.fn.filereadable(path) == 1 then
            table.insert(parts, table.concat(vim.fn.readfile(path), "\n"))
          else
            vim.notify("Bunga: missing file " .. path, vim.log.levels.WARN)
          end
        end
        return table.concat(parts, "\n\n---\n\n")
      end

      -- Load all files from a directory
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

      -- Load project .ai/ context
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
          },
        },

        adapters = {
          kiro = function()
            return require("codecompanion.adapters").extend("kiro", {})
          end,
        },
        strategies = {
          chat = { adapter = "kiro" },
          inline = { adapter = "kiro" },
        },

        rules = {
          bunga = {
            description = "Bunga persona and core rules",
            files = {
              { path = global_ai_dir, files = "*" },
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
              autoload = { "bunga", "project" },
              enabled = true,
            },
          },
        },

        prompt_library = {
          ["Bunga"] = {
            interaction = "chat",
            description = "Chat with full Bunga persona loaded",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  return load_ai_files(core_files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Laravel"] = {
            interaction = "chat",
            description = "Laravel API development with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/laravel-api.md", "skills/keycloak.md", "workflows/laravel-api.md" })
                  return load_ai_files(files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Rails"] = {
            interaction = "chat",
            description = "Legacy Rails work with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/rails.md", "workflows/legacy-rails.md" })
                  return load_ai_files(files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Neovim"] = {
            interaction = "chat",
            description = "Neovim config help with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/neovim.md" })
                  return load_ai_files(files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Debug"] = {
            interaction = "chat",
            description = "Debugging session with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/debugging.md" })
                  return load_ai_files(files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Bash"] = {
            interaction = "chat",
            description = "Bash automation scripts with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/bash.md" })
                  return load_ai_files(files)
                end,
              },
              { role = "user" },
            },
          },
          ["Bunga Review"] = {
            interaction = "chat",
            description = "Code review with Bunga",
            opts = { auto_submit = false },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/code-review.md" })
                  return load_ai_files(files)
                end,
              },
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
            opts = { auto_submit = true },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md" })
                  return load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                end,
              },
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
            opts = { auto_submit = true },
            prompts = {
              {
                role = "system",
                content = function()
                  local files = vim.deepcopy(core_files)
                  vim.list_extend(files, { "skills/laravel-api.md", "skills/code-review.md" })
                  return load_ai_files(files) .. "\n\n---\n\n" .. load_project_ai()
                end,
              },
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
      })
    end,
  },
}
