local icons = {
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
}

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        { "github/copilot.vim",                  lazy = true },
        { "hrsh7th/cmp-buffer",                  lazy = true },
        { "hrsh7th/cmp-cmdline",                 lazy = true },
        { "hrsh7th/cmp-nvim-lsp",                lazy = true },
        { "hrsh7th/cmp-nvim-lsp-signature-help", lazy = true },
        { "hrsh7th/cmp-path",                    lazy = true },
        { "hrsh7th/cmp-vsnip",                   lazy = true },
        { "octaltree/cmp-look",                  lazy = true },
        { "onsails/lspkind.nvim",                lazy = true },
    },
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")

        lspkind.init({
            mode = "symbol_text", -- Show only symbol annotations
            preset = "codicons",  -- Use Codicons for symbol icons
            symbol_map = icons,
        })

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
            local cursor = vim.api.nvim_win_get_cursor(0)
            return (vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], true)[1] or "")
                :sub(cursor[2], cursor[2])
                :match("%s")
        end

        local feedkey = function(key, mode)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                    vim.fn["vsnip#anonymous"](args.body)
                end,
            },

            window = {
                completion = {
                    border = border("FloatBorder"),                                      -- Custom border for completion window
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
                        vim_item.menu = " 󱞪 "
                            .. (
                                ({
                                    vsnip = "",
                                    buffer = "",
                                    path = "",
                                    treesitter = "󰐅",
                                    nvim_lsp = "",
                                    tags = "",
                                    rg = "󰊄",
                                    look = "󰓆",
                                })[source] or "[" .. source .. "]"
                            )

                        return vim_item
                    end,
                }),
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
                    elseif vim.fn["copilot#Accept"]("") ~= "" then
                        vim.api.nvim_feedkeys(vim.fn["copilot#Accept"]("<Tab>"), "n", true)
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
                        cmp.select_prev_item()
                    elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                        feedkey("<Plug>(vsnip-jump-prev)", "")
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            -- mapping = cmp.mapping.preset.insert({
            --     ["<C-j>"] = cmp.mapping.select_next_item(),
            --     ["<C-k>"] = cmp.mapping.select_prev_item(),
            --     ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            --     ["<C-f>"] = cmp.mapping.scroll_docs(4),
            --     ["<A-l>"] = cmp.mapping.complete(),
            --     ["<C-e>"] = cmp.mapping.abort(),
            --     ["<CR>"] = cmp.mapping.confirm({ select = false }),
            --     ["<Tab>"] = cmp.mapping(function(fallback)
            --         if cmp.visible() then
            --             cmp.select_next_item()
            --         elseif vim.fn["vsnip#available"](1) == 1 then
            --             feedkey("<Plug>(vsnip-expand-or-jump)", "")
            --         elseif has_words_before() then
            --             cmp.complete()
            --         else
            --             fallback()
            --         end
            --     end, { "i", "s" }),
            --     ["<S-Tab>"] = cmp.mapping(function(fallback)
            --         if cmp.visible() then
            --             cmp.select_next_item()
            --         elseif vim.fn["vsnip#jumpable"](-1) == 1 then
            --             feedkey("<Plug>(vsnip-jump-prev)", "")
            --         elseif has_words_before() then
            --             cmp.complete()
            --         else
            --             fallback()
            --         end
            --     end, { "i", "s" }),
            -- }),
            sources = cmp.config.sources({
                { name = "vsnip" },
                { name = "nvim_lsp",               keywords_length = 3 },
                { name = "nvim_lsp_signature_help" },
                { name = "path" },
                { name = "look",                   keywords_length = 4 },
                { name = "buffer" },
            }),
        })
        -- Set filetype-specific configuration
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
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

        vim.keymap.set('i', '<C-f>', 'copilot#Accept("\\<CR>")', {
            expr = true,
            replace_keycodes = false
        })
        vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)')
        vim.keymap.set('i', '<M-j>', '<Plug>(copilot-next)')
        vim.keymap.set('i', '<M-k>', '<Plug>(copilot-previous)')
        vim.keymap.set('i', '<M-n>', '<Plug>(copilot-accept-line)')
        vim.g.copilot_no_tab_map = true
    end,
}
