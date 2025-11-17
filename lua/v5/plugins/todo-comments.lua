return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local todo = require("todo-comments")

        todo.setup({
            signs = true,
            sign_priority = 8,

            keywords = {
                TODO = { icon = "", color = "info" },
                FIX = { icon = "", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "DEBUG" } },
                HACK = { icon = "", color = "warning" },
                WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = "", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = "", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
                SPEC = { icon = "", color = "test", alt = { "SPECIFICATION", "BEHAVIOR" } },
                MOCK = { icon = "🧪", color = "test", alt = { "STUB", "FAKE" } },
                REFACTOR = { icon = "", color = "hint", alt = { "CLEANUP", "IMPROVE" } },
            },

            highlight = {
                multiline = true,
                multiline_pattern = "^.",
                multiline_context = 5,
                before = "",
                keyword = "wide",
                after = "fg",

                -- ✅ fully valid Vim regex
                pattern = [[\v<(KEYWORDS)>\s*:]],

                comments_only = true,
                max_line_len = 400,
                exclude = {},
            },

            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" },
            },

            search = {
                command = "rg",
                args = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                },

                -- ✅ valid ripgrep regex
                pattern = [[\b(KEYWORDS):]],
            },
        })

        ------------------------------------------------------------------------
        -- ✅ Keymaps (cleaned up)
        ------------------------------------------------------------------------
        vim.keymap.set("n", "]t", todo.jump_next, { desc = "Next TODO comment" })
        vim.keymap.set("n", "[t", todo.jump_prev, { desc = "Previous TODO comment" })

        ------------------------------------------------------------------------
        -- ✅ Telescope directory picker (optimized, same behavior)
        ------------------------------------------------------------------------
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values
        local scan = require("plenary.scandir")
        local fn = vim.fn

        local dir_cache = nil
        local recent_dirs = {}

        vim.keymap.set("n", "<leader>st", function()
            local cwd = fn.getcwd()

            -- ✅ Cache the directory list (first run only)
            if not dir_cache then
                local abs_dirs = scan.scan_dir(cwd, {
                    only_dirs = true,
                    depth = 7,                -- ✅ you asked to keep this
                    respect_gitignore = true,
                })

                dir_cache = vim.tbl_map(function(dir)
                    return {
                        display = fn.fnamemodify(dir, ":."), -- show relative path
                        value = dir,                         -- actual directory
                    }
                end, abs_dirs)
            end

            -- ✅ Merge recent dirs + cached dirs (unique)
            local seen = {}
            local entries = {}

            local function add(entry)
                if not seen[entry.value] then
                    seen[entry.value] = true
                    table.insert(entries, entry)
                end
            end

            for _, e in ipairs(recent_dirs) do add(e) end
            for _, e in ipairs(dir_cache) do add(e) end

            -- ✅ Telescope picker
            pickers.new({}, {
                prompt_title = "Select directory for TODO search",
                finder = finders.new_table({
                    results = entries,
                    entry_maker = function(e)
                        return {
                            value = e.value,
                            display = e.display,
                            ordinal = e.display,
                        }
                    end,
                }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local entry = action_state.get_selected_entry()
                        local dir = entry.value

                        -- ✅ update recent dirs MRU list
                        table.insert(recent_dirs, 1, {
                            value = dir,
                            display = fn.fnamemodify(dir, ":."),
                        })

                        -- unique filter
                        local s = {}
                        recent_dirs = vim.tbl_filter(function(item)
                            if s[item.value] then return false end
                            s[item.value] = true
                            return true
                        end, recent_dirs)

                        vim.cmd("TodoTelescope cwd=" .. fn.fnameescape(dir))
                    end)
                    return true
                end,
            }):find()
        end, { desc = "Search TODOs in selected directory" })
    end,
}
