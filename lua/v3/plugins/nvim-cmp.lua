return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "onsails/lspkind.nvim", lazy = true },
        { "hrsh7th/cmp-nvim-lsp", lazy = true },
        { "hrsh7th/cmp-buffer", lazy = true },
        { "hrsh7th/cmp-path", lazy = true },
        { "hrsh7th/cmp-cmdline", lazy = true },
        { "hrsh7th/cmp-nvim-lsp-signature-help", lazy = true },
        { "hrsh7th/cmp-vsnip", lazy = true },
        { "davidsierradz/cmp-conventionalcommits", lazy = true },
        { "jcha0713/cmp-tw2css", lazy = true },
        { "delphinus/cmp-ctags", lazy = true },
        { "lukas-reineke/cmp-rg", lazy = true },
        { "ray-x/cmp-treesitter", lazy = true },
    },
    config = function()
        -- Initialize LSPKind for rich completion icons
        require("lspkind").init({
            mode = "symbol_text", -- Show only symbol annotations
            preset = "codicons", -- Use Codicons for symbol icons
            symbol_map = {
                -- Override default symbols with Codicons
                Text = "󰊄", -- 󰊄
                Method = "", -- 
                Function = "󰊕", -- 󰊕
                Constructor = "",
                Field = "", -- ﰠ
                Variable = "", -- 
                Class = "", -- ﴯ
                Interface = "",
                Module = "",
                Property = "", -- ﰠ
                Unit = "塞",
                Value = "󰫧", -- 󰫧
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "", -- 
                File = "", -- 
                Reference = "",
                Folder = "", -- 
                EnumMember = "",
                Constant = "",
                Struct = "פּ",
                Event = "",
                Operator = "", -- 
                TypeParameter = "",
                Copilot = "",
            },
        })

        if not table.unpack then
            table.unpack = unpack
        end

        -- Function to define custom borders for completion and documentation windows
        local function border(hl_name)
            return {
                { "┌", hl_name },
                { "─", hl_name },
                { "┐", hl_name },
                { "│", hl_name },
                { "┘", hl_name },
                { "─", hl_name },
                { "└", hl_name },
                { "│", hl_name },
            }
        end

        local has_words_before = function()
            local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
        end

        -- Configure cmp for auto-completion
        local cmp = require("cmp")
        cmp.setup({
            completion = {
                completeopt = "longest,menu,preview",
                -- autocomplete = true,
            },
            window = {
                completion = {
                    border = border("FloatBorder"), -- Custom border for completion window
                    winhighlight = "Normal:NormalFloat,CursorLine:PmenuSel,Search:None", -- Highlight configuration
                },
                documentation = {
                    border = border("FloatBorder"), -- Custom border for documentation window
                },
            },
            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = require("lspkind").cmp_format({
                    -- mode = "symbol_text", -- Show only symbol annotations
                    mode = "symbol_text", -- Show only symbol annotations
                    before = function(entry, vim_item)
                        local source = entry.source.name
                        local kind = vim_item.kind
                        -- Customize menu item annotations based on source
                        vim_item.menu = ({
                            vsnip = "",
                            buffer = "",
                            path = "",
                            treesitter = "󰐅",
                            nvim_lsp = "",
                            tags = "",
                            rg = "󰊄",
                        })[entry.source.name]

                        -- vim_item.dup = 0

                        return vim_item
                    end,
                }),
            },
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body) -- For vsnip users
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<A-l>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif vim.fn["vsnip#available"](1) == 1 then
                        feedkey("<Plug>(vsnip-expand-or-jump)", "")
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                        feedkey("<Plug>(vsnip-jump-prev)", "")
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                -- { name = 'copilot' },
                { name = "vsnip", priority = 100 },
                { name = "buffer", priority = 90 },
                { name = "path", priority = 80 },
                { name = "treesitter", priority = 70 },
                { name = "nvim_lsp_signature_help", priority = 50 },
                {
                    name = "nvim_lsp",
                    priority = 30,
                    entry_filter = function(entry, _)
                        if entry:get_kind() == 1 then
                            return false
                        end
                        return true
                    end,
                },
                { name = "ctags", priority = 20 },
            }, {
                { name = "rg", priority = 10 },
                { name = "buffer" },
            }),
            experimental = {
                ghost_text = false,
            },
            sorting = {
                comparators = {
                    cmp.config.compare.exact,
                    cmp.config.compare.offset,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.scopes,
                    cmp.config.compare.locality,
                    function(entry1, entry2)
                        local result = vim.stricmp(entry1.completion_item.label, entry2.completion_item.label)
                        if result < 0 then
                            return true
                        end
                        return false
                    end,
                },
            },
        })

        -- Set filetype-specific configuration
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "conventionalcommits" },
                { name = "vsnip" },
            }, {
                { name = "buffer" },
            }),
        })

        -- Cmdline completion for '/', '?', and ':'
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })

        -- Additional cmdline configuration for ':'
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })
    end,
}
