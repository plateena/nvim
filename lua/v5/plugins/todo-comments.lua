return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("todo-comments").setup({
            signs = true,      -- show icons in the signs column
            sign_priority = 8, -- sign priority
            -- keywords recognized as todo comments
            keywords = {
                TODO = { icon = " ", color = "info" },

                FIX = {
                    icon = " ",
                    color = "error",
                    alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "DEBUG" },
                },

                HACK = { icon = " ", color = "warning" },

                WARN = {
                    icon = " ",
                    color = "warning",
                    alt = { "WARNING", "XXX" },
                },

                PERF = {
                    icon = " ",
                    color = "hint",
                    alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
                },

                NOTE = {
                    icon = " ",
                    color = "hint",
                    alt = { "INFO" },
                },

                TEST = {
                    icon = "⏲ ",
                    color = "test",
                    alt = { "TESTING", "PASSED", "FAILED" },
                },

                SPEC = {
                    icon = "📄",
                    color = "test",
                    alt = { "SPECIFICATION", "BEHAVIOR" },
                },

                MOCK = {
                    icon = "🧪",
                    color = "test",
                    alt = { "STUB", "FAKE" },
                },

                REFACTOR = {
                    icon = "♻️",
                    color = "hint",
                    alt = { "CLEANUP", "IMPROVE" },
                },
            },
            gui_style = {
                fg = "NONE",       -- The gui style to use for the fg highlight group.
                bg = "BOLD",       -- The gui style to use for the bg highlight group.
            },
            merge_keywords = true, -- when true, custom keywords will be merged with the defaults
            -- highlighting of the line containing the todo comment
            -- * before: highlights before the keyword (typically comment characters)
            -- * keyword: highlights of the keyword
            -- * after: highlights after the keyword (todo text)
            highlight = {
                multiline = true,                -- enable multine todo comments
                multiline_pattern = "^.",        -- lua pattern to match the next multiline from the start of the matched keyword
                multiline_context = 5,           -- extra lines that will be re-evaluated when changing a line (reduced for better performance)
                before = "",                     -- "fg" or "bg" or empty
                keyword = "wide",                -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                after = "fg",                    -- "fg" or "bg" or empty
                pattern = {
                    [[.*<(KEYWORDS)\s*:]],       -- Default pattern
                    [[.*#\s*(KEYWORDS)\s*:]],    -- Ruby/Bash comments
                    [[.*//\s*(KEYWORDS)\s*:]],   -- JavaScript comments
                    [[.*<!--\s*(KEYWORDS)\s*:]], -- HTML comments
                },                               -- pattern or table of patterns, used for highlighting (vim regex)
                comments_only = true,            -- uses treesitter to match keywords in comments only
                max_line_len = 400,              -- ignore lines longer than this
                exclude = {},                    -- list of file types to exclude highlighting
            },
            -- list of named colors where we try to extract the guifg from the
            -- list of highlight groups or use the hex color if hl not found as a fallback
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
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
            },
        })

        -- Set up useful keymaps for todo navigation
        local map = vim.keymap.set
        map("n", "]t", function()
            require("todo-comments").jump_next()
        end, { desc = "Next todo comment" })

        map("n", "[t", function()
            require("todo-comments").jump_prev()
        end, { desc = "Previous todo comment" })

        local map = vim.keymap.set
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local conf = require("telescope.config").values

        map("n", "<leader>st", function()
            local scan = require("plenary.scandir")
            local cwd = vim.fn.getcwd()

            -- Absolute paths
            local abs_dirs = scan.scan_dir(cwd, {
                only_dirs = true,
                depth = 3,
                respect_gitignore = true,
            })

            -- Show relative paths in Telescope UI
            local entries = vim.tbl_map(function(dir)
                return {
                    display = vim.fn.fnamemodify(dir, ":."), -- relative from cwd
                    value = dir,                     -- actual full path for execution
                }
            end, abs_dirs)

            pickers.new({}, {
                prompt_title = "Select directory for TODO search",
                finder = finders.new_table {
                    results = entries,
                    entry_maker = function(entry)
                        return {
                            value = entry.value,
                            display = entry.display,
                            ordinal = entry.display,
                        }
                    end,
                },
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local entry = action_state.get_selected_entry()
                        local selected_dir = entry.value
                        vim.cmd("TodoTelescope cwd=" .. vim.fn.fnameescape(selected_dir))
                    end)
                    return true
                end,
            }):find()
        end, { desc = "Search TODOs in selected directory" })
    end,
}
