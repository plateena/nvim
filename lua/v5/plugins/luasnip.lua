return {
    "L3MON4D3/LuaSnip",
    enabled = true,
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "honza/vim-snippets",
    },
    event = { "InsertEnter", "CmdlineEnter" }, -- Lazy load on insert mode
    config = function()
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")

        -- Load snippets from various sources
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()

        -- Load custom Lua snippets with error handling
        local custom_snippets_path = vim.fn.stdpath("config") .. "/snippets/luasnip"
        if vim.fn.isdirectory(custom_snippets_path) == 1 then
            require("luasnip.loaders.from_lua").load({
                paths = { custom_snippets_path },
            })
        end

        -- Enhanced LuaSnip configuration
        luasnip.config.setup({
            enable_autosnippets = true,
            store_selection_keys = "<C-s>", -- For visual selection snippets
            update_events = { "TextChangedI", "TextChangedP" },
            delete_check_events = { "TextChanged", "InsertLeave" },
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { "●", "DiagnosticWarn" } },
                        hl_group = "LuasnipChoiceNodeActive",
                    },
                    passive = {
                        virt_text = { { "○", "DiagnosticHint" } },
                        hl_group = "LuasnipChoiceNodePassive",
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { "●", "DiagnosticInfo" } },
                        hl_group = "LuasnipInsertNodeActive",
                    },
                    passive = {
                        virt_text = { { "○", "DiagnosticHint" } },
                        hl_group = "LuasnipInsertNodePassive",
                    },
                },
            },
        })

        vim.api.nvim_create_user_command("LuaSnipFindTrigger", function(opts)
            local trigger_name = opts.args
            local ls = require("luasnip")
            local found = {}

            -- Get all filetypes with snippets
            for ft, snip_map in pairs(ls.snippets or {}) do
                for trig, snip in pairs(snip_map) do
                    if trig == trigger_name then
                        local src = snip.user_data and snip.user_data.source_file or "unknown"
                        table.insert(found, string.format("ft: %-10s  trigger: %-10s  source: %s", ft, trig, src))
                    end
                end
            end

            if #found == 0 then
                print("No snippets found for trigger: " .. trigger_name)
            else
                print("Snippets for trigger `" .. trigger_name .. "`:")
                for _, line in ipairs(found) do
                    print("  " .. line)
                end
            end
        end, {
            nargs = 1,
            complete = function()
                return {}
            end,
            desc = "Show all LuaSnip snippet files for given trigger",
        })

        -- Key mappings for snippet navigation (using non-conflicting keys)
        vim.keymap.set({ "i", "s" }, "<Tab>", function()
            if require("luasnip").expand_or_locally_jumpable() then
                return "<Plug>luasnip-expand-or-jump"
            else
                return "<Tab>"
            end
        end, { expr = true, silent = true })

        vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
            if require("luasnip").jumpable(-1) then
                return "<Plug>luasnip-jump-prev"
            else
                return "<S-Tab>"
            end
        end, { expr = true, silent = true })

        vim.keymap.set({ "i", "s" }, "<C-p>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(1)
            else
                return "<C-p>"
            end
        end, { desc = "Cycle forward through choice nodes", silent = true })

        vim.keymap.set({ "i", "s" }, "<C-n>", function()
            if luasnip.choice_active() then
                luasnip.change_choice(-1)
            else
                return "<C-n>"
            end
        end, { desc = "Cycle backward through choice nodes", silent = true })

        -- Exit snippet mode with Escape
        vim.keymap.set({ "i", "s" }, "<Esc>", function()
            if luasnip.in_snippet() then
                luasnip.unlink_current()
            end
            return "<Esc>"
        end, { expr = true, desc = "Exit snippet mode", silent = true })

        -- Add highlight groups for better visual feedback
        vim.api.nvim_set_hl(0, "LuasnipChoiceNodeActive", { fg = "#ff9500", bold = true })
        vim.api.nvim_set_hl(0, "LuasnipChoiceNodePassive", { fg = "#7c7c7c" })
        vim.api.nvim_set_hl(0, "LuasnipInsertNodeActive", { fg = "#00d7ff", bold = true })
        vim.api.nvim_set_hl(0, "LuasnipInsertNodePassive", { fg = "#7c7c7c" })
    end,
}
