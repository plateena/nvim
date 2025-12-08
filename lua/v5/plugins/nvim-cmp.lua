return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "David-Kunz/cmp-npm",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-path",
        "onsails/lspkind.nvim",
        "petertriho/cmp-git",
        "ray-x/cmp-treesitter",
        "saadparwaiz1/cmp_luasnip",
    },

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        local icons = {
            Function = "󰊕",
            TreesitterContext = "󰐅",
            Copilot = "",
        }

        lspkind.init({
            mode = "symbol_text",
            preset = "default",
            symbol_map = icons,
        })

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
                    winhighlight = "Normal:NormalFloat,CursorLine:PmenuSel,Search:None",
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
                        local labels = {
                            buffer = "[Buffer]",
                            luasnip = "[Snip]",
                            path = "[Path]",
                            treesitter = "[TS]",
                            npm = "[NPM]",
                            git = "[Git]",
                        }
                        local icons = {
                            buffer = "󰈙",
                            luasnip = "󰞷",
                            path = "",
                            treesitter = "󰐅",
                            npm = "",
                            git = "",
                        }

                        local src = entry.source.name
                        vim_item.menu = string.format("%s %s", icons[src] or "", labels[src] or "[Other]")
                        return vim_item
                    end,
                }),
            },

            mapping = {
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-k>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i" }),
            },

            sources = cmp.config.sources({
                { name = "luasnip", priority = 750 },
                { name = "nvim_lsp", priority = 700 },
                { name = "treesitter", priority = 650 },
                { name = "buffer", priority = 500 },
                { name = "path", priority = 250 },
            }),

            performance = {
                debounce = 100,
                throttle = 60,
                fetching_timeout = 200,
                max_view_entries = 30,
            },

            experimental = {
                ghost_text = { hl_group = "Comment" },
            },
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "path" },
                { name = "cmdline" },
            },
        })

        local ok_npm, cmp_npm = pcall(require, "cmp-npm")
        if ok_npm then
            cmp_npm.setup({ only_semantic_versions = true })
        end

        local ok_git, cmp_git = pcall(require, "cmp_git")
        if ok_git then cmp_git.setup() end
    end,
}
