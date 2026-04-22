return {
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"nvimtools/none-ls.nvim",
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"ruff",
					"shfmt",
					"stylua",
					"prettier",
				},
				handlers = {},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.diagnostics.semgrep.with({
						method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
						disabled_filetypes = { "python" },
					}),
				},
			})

			vim.keymap.set("n", "<leader>nf", vim.lsp.buf.format, { desc = "Format current buffer" })
		end,
	},
}
