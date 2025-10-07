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
					"stylua",
					"cpplint",
					"clang-format",
				},
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					require("none-ls.formatting.ruff"),
					require("none-ls.diagnostics.ruff"),
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.clang_format,
					null_ls.builtins.diagnostics.cpplint,
				},
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ async = false })
							end,
						})
					end
				end,
			})

			vim.keymap.set("n", "<leader>nf", vim.lsp.buf.format, { desc = "Format current buffer" })
		end,
	},
}
