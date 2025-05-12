return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-path",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            dependencies = {
                "rafamadriz/friendly-snippets",
                "honza/vim-snippets",
            },
        },
        "onsails/lspkind.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        -- Enhanced icon set with better visual hierarchy
        local icons = {
            Text = "",
            Method = "",
            Function = "󰊕",
            Constructor = "",
            Field = "",
            Variable = "",
            Class = "",
            Interface = "",
            Module = "",
            Property = "",
            Unit = "",
            Value = "",
            Enum = "",
            Keyword = "",
            Snippet = "",
            Color = "",
            File = "",
            Reference = "",
            Folder = "",
            EnumMember = "",
            Constant = "",
            Struct = "",
            Event = "",
            Operator = "",
            TypeParameter = "",
            Copilot = "",
            Codeium = "",
            TabNine = "",
        }

        -- Load snippets from friendly-snippets and vim-snippets
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()

        -- Initialize lspkind with better defaults
        lspkind.init({
            mode = "symbol_text",
            preset = "default",
            symbol_map = icons,
        })

        -- Unified border configuration
        local border = {
            { "╭", "CmpBorder" },
            { "─", "CmpBorder" },
            { "╮", "CmpBorder" },
            { "│", "CmpBorder" },
            { "╯", "CmpBorder" },
            { "─", "CmpBorder" },
            { "╰", "CmpBorder" },
            { "│", "CmpBorder" },
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
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    before = function(entry, vim_item)
                        local source_icons = {
                            buffer = "󰈙",
                            nvim_lsp = "",
                            luasnip = "󰞷",
                            nvim_lua = "",
                            path = "",
                            cmdline = "",
                        }
                        vim_item.menu = string.format(" %s", source_icons[entry.source.name] or "")
                        return vim_item
                    end,
                }),
            },
            mapping = {
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-l>"] = cmp.mapping(function()
                    if luasnip.choice_active() then
                        luasnip.change_choice(1)
                    end
                end, { "i", "s" }),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "luasnip" },
                { name = "buffer", keyword_length = 3 },
                { name = "path" },
            }),
            -- performance = {
            --     debounce = 100,
            --     throttle = 60,
            --     fetching_timeout = 200,
            --     max_view_entries = 30,
            -- },
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
                { name = "git" },
                { name = "buffer" },
            })
        })

        cmp.setup.filetype("markdown", {
            sources = cmp.config.sources({
                { name = "buffer" },
                { name = "path" },
                { name = "luasnip" },
            })
        })

        -- Improved cmdline configuration
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" }
            },
            view = {
                entries = { name = "wildmenu", separator = "|" }
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
                { { name = "path" } },
                { { name = "cmdline", keyword_pattern = [=[[^[:blank:]\!]*]=] } }
            ),
        })

        -- Additional snippet keymaps
        vim.keymap.set({ "i", "s" }, "<C-j>", function()
            if luasnip.jumpable(1) then
                luasnip.jump(1)
            end
        end)

        vim.keymap.set({ "i", "s" }, "<C-k>", function()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end)
    end,
}
