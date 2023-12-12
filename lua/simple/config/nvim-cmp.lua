-- In your init.lua

local cmp = require("cmp")

cmp.setup({
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<C-e>"] = cmp.mapping.close(),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		-- Add more sources as needed
	},
	completion = { completeopt = "menu,menuone,noinsert" },
	snippet = { expand = function(args) end },
	formatting = { format = function(entry, vim_item)
		-- vim_item.kind =
		-- require(
		-- 	"lspkind"
		-- ).presets.default[vim_item.kind] .. " " .. vim_item.kind
		vim_item.menu = ({
			nvim_lsp = "[LSP]",
			buffer = "[Buffer]",
			path = "[Path]",
			nvim_lua = "[Lua]",
			luasnip = "[Snip]",
		})[entry.source.name]
		return vim_item
	end },
})
