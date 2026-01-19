return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "bashls", "yamlls", "lua_ls", "marksman" },

				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●", -- You can choose your own prefix or symbol
				},
				signs = false, -- Always show diagnostic signs
				underline = true, -- Underline text with diagnostics
				update_in_insert = false, -- Update diagnostics while typing
				severity_sort = true, -- Sort diagnostics by severity
				float = {
					focusable = false, -- Disable floating window to avoid jumps
					border = "rounded", -- Rounded borders for the floating window if enabled
				},
			})

			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Open code actions" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
		end,
	},
}
