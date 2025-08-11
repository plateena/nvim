return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "David-Kunz/cmp-npm", -- Added npm package completion
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-path",
        "onsails/lspkind.nvim",
        "petertriho/cmp-git",   -- Added git completion (was missing)
        "ray-x/cmp-treesitter", -- Added treesitter completion
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- Enhanced icon set with better visual hierarchy
        local icons = {
            Text = "",
            Method = "",
            Function = "󰊕",
            Constructor = "",
            Field = "",
            Variable = "",
            Class = "",
            Interface = "",
            Module = "",
            Property = "",
            Unit = "",
            Value = "",
            Enum = "",
            Keyword = "",
            Snippet = "",
            Color = "",
            File = "",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = "",
            Event = "",
            Operator = "",
            TypeParameter = "",
            Copilot = "",
            Codeium = "",
            TabNine = "",
            TreesitterContext = "󰐅", -- Icon for treesitter
            Npm = "", -- Icon for npm packages
        }

        -- Initialize lspkind with better defaults
        lspkind.init({
            mode = "symbol_text",
            preset = "default",
            symbol_map = icons,
        })

        -- Unified border configuration
        local border = {
            { "╭", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╮", "FloatBorder" },
            { "│", "FloatBorder" },
            { "╯", "FloatBorder" },
            { "─", "FloatBorder" },
            { "╰", "FloatBorder" },
            { "│", "FloatBorder" },
        }

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            window = {
                completion = {
                    border = border,
                    winhighlight = "Normal:NormalFloat,CursorLine:PmenuSel,Search:None",
                    scrollbar = false,
                    col_offset = -1,
                    side_padding = 0,
                },
                documentation = {
                    border = border,
                    max_width = 80,
                    max_height = 20,
                },
            },
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = require("lspkind").cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    before = function(entry, vim_item)
                        local source_labels = {
                            buffer     = "[Buffer]",
                            -- nvim_lsp   = "[LSP]",
                            luasnip    = "[LuaSnip]",
                            nvim_lua   = "[Lua]",
                            path       = "[Path]",
                            cmdline    = "[Cmd]",
                            treesitter = "[TS]",
                            npm        = "[NPM]",
                            git        = "[Git]",
                        }

                        local source_icons = {
                            buffer     = "󰈙",
                            -- nvim_lsp   = "",
                            luasnip    = "󰞷",
                            nvim_lua   = "",
                            path       = "",
                            cmdline    = "",
                            treesitter = "󰐅",
                            npm        = "",
                            git        = "",
                        }

                        local icon = source_icons[entry.source.name] or ""
                        local label = source_labels[entry.source.name] or "[Other]"

                        vim_item.menu = string.format("%s %s", icon, label)
                        return vim_item
                    end,
                }),
            },
            mapping = {
                -- Scroll documentation
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

                -- Force completion
                ["<C-k>"] = cmp.mapping.complete(),

                -- Abort completion
                ["<C-e>"] = cmp.mapping.abort(),

                -- Confirm completion
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }),

                -- Enhanced Tab - handles both completion and snippets
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Enhanced Shift-Tab - handles both completion and snippets
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Choice navigation (forward) - only when not in completion menu
                ["<C-p>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.choice_active() then
                        luasnip.change_choice(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- Choice navigation (backward) - only when not in completion menu
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                    elseif luasnip.choice_active() then
                        luasnip.change_choice(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            },
            sources = cmp.config.sources({
                -- { name = "nvim_lsp_signature_help", priority = 1000 },
                { name = "luasnip",    priority = 750 },
                { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 850, keyword_length = 2 },
                { name = "buffer",     priority = 500, keyword_length = 3 },
                { name = "path",       priority = 250 },
            }),
            performance = {
                debounce = 100,
                throttle = 60,
                fetching_timeout = 200,
                max_view_entries = 30,
            },
            experimental = {
                ghost_text = {
                    hl_group = "Comment",
                },
                native_menu = false,
            },
        })

        -- Enhanced filetype-specific configurations
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "luasnip" },
                { name = "git" },
                { name = "buffer" },
            })
        })

        cmp.setup.filetype("markdown", {
            sources = cmp.config.sources({
                { name = "buffer" },
                { name = "path" },
                { name = "luasnip" },
                { name = "treesitter", keyword_length = 2 },
            })
        })

        -- JavaScript/TypeScript specific configuration with npm support
        cmp.setup.filetype({ "javascript", "typescript", "javascriptreact", "typescriptreact" }, {
            sources = cmp.config.sources({
                { name = "copilot",    priority = 1000 },
                { name = "npm",        priority = 900 },
                { name = "luasnip",    priority = 750 },
                -- { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer",     priority = 500, keyword_length = 3 },
                { name = "path",       priority = 250 },
            })
        })

        -- JSON files (package.json, composer.json, etc.) with npm support
        cmp.setup.filetype("json", {
            sources = cmp.config.sources({
                { name = "npm",        priority = 899 },
                { name = "luasnip",    priority = 750 },
                -- { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer",     priority = 500 },
                { name = "path",       priority = 250 },
            })
        })

        -- Ruby configuration (for your Ruby development)
        cmp.setup.filetype("ruby", {
            sources = cmp.config.sources({
                { name = "copilot",    priority = 1000 },
                { name = "luasnip",    priority = 750 },
                -- { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer",     priority = 500, keyword_length = 3 },
                { name = "path",       priority = 250 },
            })
        })

        -- PHP configuration (for your Laravel development)
        cmp.setup.filetype("php", {
            sources = cmp.config.sources({
                { name = "copilot",    priority = 1000 },
                { name = "luasnip",    priority = 750 },
                -- { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer",     priority = 500, keyword_length = 3 },
                { name = "path",       priority = 250 },
            })
        })

        -- Shell script configuration (for your bash scripting)
        cmp.setup.filetype({ "sh", "bash", "zsh" }, {
            sources = cmp.config.sources({
                { name = "luasnip",    priority = 750 },
                -- { name = "nvim_lsp",   priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer",     priority = 500, keyword_length = 2 },
                { name = "path",       priority = 800 }, -- Higher priority for shell scripts
            })
        })

        -- For `/` and `?` (search) cmdline
        cmp.setup.cmdline({ "/", "?" }, {
            completion = { completeopt = "menu,menuone,noselect" },
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
            view = { entries = { name = "wildmenu", separator = "|" } },
        })

        -- For `:` command-line mode
        cmp.setup.cmdline(":", {
            completion = { completeopt = "menu,menuone,noselect" },
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
                { { name = "path" } },
                { { name = "cmdline" } }
            ),
        })

        -- Additional snippet keymaps
        vim.keymap.set({ "i", "s" }, "<C-j>", function()
            if luasnip.jumpable(1) then
                luasnip.jump(1)
            end
        end, { desc = "Jump to next snippet placeholder" })

        vim.keymap.set({ "i", "s" }, "<C-k>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { desc = "Jump to previous snippet placeholder" })

        -- Setup cmp-npm if available
        local npm_ok, cmp_npm = pcall(require, "cmp-npm")
        if npm_ok then
            cmp_npm.setup({
                ignore = {},                   -- ignore specific packages
                only_semantic_versions = true, -- only show semantic versions
            })
        end

        -- Setup cmp-git if available
        local git_ok, cmp_git = pcall(require, "cmp_git")
        if git_ok then
            cmp_git.setup()
        end
    end,
}
