return {
  "stevearc/conform.nvim",
  ft = {
    "javascript",
    "typescript",
    "php",
    "html",
    "css",
    "scss",
    "lua",
    "bash",
    "sh",
    "tsx",
    "jsx",
    "yaml",
    "json",
    "markdown",
    "ruby",
  },
  keys = {
    {
      "<leader>mp",
      function()
        if vim.fn.mode():match("[vV]") then
          local s_pos = vim.fn.getpos("'<")
          local e_pos = vim.fn.getpos("'>")
          require("conform").format({
            range = {
              start = { s_pos[2], s_pos[3] - 1 },
              ["end"] = { e_pos[2], e_pos[3] - 1 },
            },
          })
        else
          require("conform").format()
        end
      end,
      mode = { "n", "v" },
      desc = "Format code or selected range",
    },
  },
  config = function()
    local conform = require("conform")
    local util = require("conform.util")

    local global_prettier = "/home/mzd/.config/nvm/versions/node/v24.11.0/bin/prettier"
    local fallback_config = vim.fn.expand("~/.prettierrc.json")

    -- Function to find local prettier executable
    local function find_local_prettier(ctx)
      -- Use vim.fs.root for modern Neovim (0.10+)
      local project_root = vim.fs.root(0, {
        "package.json",
        "pnpm-workspace.yaml",
        "yarn.lock",
        "pnpm-lock.yaml",
        "lerna.json",
        "tsconfig.json",
        ".git",
        "Gemfile",
        "Rakefile",
        "composer.json",
        "Cargo.toml",
        "Makefile",
        "pyproject.toml",
        "Dockerfile",
        "docker-compose.yml",
        "docker-compose.yaml",
        ".github/workflows", -- GitHub Actions
        ".gitlab-ci.yml", -- GitLab CI
        "bitbucket-pipelines.yml", -- Bitbucket Pipelines
        ".circleci/config.yml", -- CircleCI
        ".travis.yml", -- Travis CI
      })

      if not project_root then
        return nil
      end

      -- Check for local prettier in node_modules/.bin
      local local_prettier = project_root .. "/node_modules/.bin/prettier"
      if vim.uv.fs_stat(local_prettier) then
        return local_prettier
      end

      -- Check package.json for prettier dependency
      local package_json = project_root .. "/package.json"
      if vim.uv.fs_stat(package_json) then
        local ok, content = pcall(vim.fn.readfile, package_json)
        if ok and content then
          local package_content = vim.fn.json_decode(table.concat(content, "\n"))
          if
            package_content
            and (
              (package_content.dependencies and package_content.dependencies.prettier)
              or (package_content.devDependencies and package_content.devDependencies.prettier)
            )
          then
            return "npx"
          end
        end
      end

      return nil
    end

    -- Function to check for local prettier config
    local function find_local_prettier_config(cwd)
      if not cwd then
        return nil
      end

      local config_files = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        "prettier.config.js",
        ".editorconfig",
      }

      for _, file in ipairs(config_files) do
        local filepath = cwd .. "/" .. file
        if vim.uv.fs_stat(filepath) then
          return filepath
        end
      end

      -- Check package.json for prettier config
      local package_json = cwd .. "/package.json"
      if vim.uv.fs_stat(package_json) then
        local ok, content = pcall(vim.fn.readfile, package_json)
        if ok and content then
          local package_content = vim.fn.json_decode(table.concat(content, "\n"))
          if package_content and package_content.prettier then
            return package_json
          end
        end
      end

      -- Check parent directories for config
      local parent = vim.fn.fnamemodify(cwd, ":h")
      if parent ~= cwd then
        return find_local_prettier_config(parent)
      end

      return nil
    end

    conform.setup({
      log_level = vim.log.levels.DEBUG,

      formatters = {
        prettier = {
          meta = {
            url = "https://prettier.io/",
            description = "Prettier formatter with local/global fallback",
          },
          command = function(self, ctx)
            local local_prettier = find_local_prettier(ctx)

            if local_prettier then
              if local_prettier == "npx" then
                return "npx"
              end
              return local_prettier
            end

            -- Fallback to global prettier
            vim.notify("Using global prettier (no local prettier found)", vim.log.levels.INFO)
            return global_prettier
          end,
          args = function(self, ctx)
            local args = {
              "--stdin-filepath",
              "$FILENAME",
              "--log-level=debug",
            }

            -- Get current working directory
            local bufname = ctx.filename
            local buf_dir = vim.fn.fnamemodify(bufname, ":h")

            -- Check for config in current buffer's directory
            local local_config = find_local_prettier_config(buf_dir)

            if not local_config then
              -- No local config found, use fallback
              vim.notify("No local prettier config found, using fallback config", vim.log.levels.INFO)
              table.insert(args, "--config")
              table.insert(args, fallback_config)
            else
              -- Found local config, prettier will automatically use it
              vim.notify("Using local prettier config: " .. local_config, vim.log.levels.INFO)
            end

            return args
          end,
          range_args = function(self, ctx)
            local args = {
              "--stdin-filepath",
              "$FILENAME",
              "--range-start",
              tostring(ctx.range.start[1]),
              "--range-end",
              tostring(ctx.range["end"][1]),
            }

            -- Get current working directory
            local bufname = ctx.filename
            local buf_dir = vim.fn.fnamemodify(bufname, ":h")

            local local_config = find_local_prettier_config(buf_dir)

            if not local_config then
              table.insert(args, "--config")
              table.insert(args, fallback_config)
            end

            return args
          end,
          stdin = true,
          tmpfile_format = ".conform.$RANDOM.$FILENAME",
          cwd = util.root_file({
            "package.json",
            ".git",
            "node_modules",
          }),
        },
        rubocop = {
          command = "rubocop",
          args = { "--stdin", "$FILENAME", "--autocorrect", "--format", "quiet", "--stderr" },
          stdin = true,
        },
        phpcbf = {
          command = "phpcbf",
          args = { "--standard=PSR12", "-" },
          stdin = true,
        },
        shfmt = {
          command = "shfmt",
          args = { "-i", "2", "-" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        php = { "prettier" },
        ruby = { "rubocop" },
        sh = { "shfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        jsx = { "prettier" },
        tsx = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        yaml = { "prettier" },
      },
      format_on_save = function(bufnr)
        if vim.g.format_on_save_enabled then
          return {
            timeout_ms = 10000,
            lsp_format = "fallback",
          }
        end
      end,
    })
  end,
}
