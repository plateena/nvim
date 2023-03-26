local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.code_actions.gitsigns,

		null_ls.builtins.formatting.stylua,

		null_ls.builtins.diagnostics.eslint,
		null_ls.builtins.diagnostics.phpcs.with({
			diagnostic_config = {
				-- see :help vim.diagnostic.config()
				underline = true,
				virtual_text = false,
				signs = true,
				update_in_insert = false,
				severity_sort = true,
			},
		}),

		null_ls.builtins.completion.spell,
		null_ls.builtins.completion.tags,
		null_ls.builtins.completion.vsnip,
	},
})
