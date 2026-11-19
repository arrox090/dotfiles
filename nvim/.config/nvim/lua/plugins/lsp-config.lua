return {
	-- Automatically configures lua_ls for Neovim (removes "Undefined global vim")
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
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
				ensure_installed = {
					"lua_ls", -- Lua (Neovim configs)
					"pyright", -- Python
					"clangd", -- C / C++
					"bashls", -- Bash
					"marksman", -- Markdown (Notes & AI context)
					"yamlls", -- YAML (Docker compose)
					"biome", -- JSON / JSONC / JS / TS
					"sqlls", -- SQL
				},

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
					prefix = "●",
				},
				signs = false, -- Don't show diagnostic signs
				underline = true, -- Underline text with diagnostics
				update_in_insert = false, -- Update diagnostics while typing
				severity_sort = true, -- Sort diagnostics by severity
				float = {
					focusable = false, -- Disable floating window to avoid jumps
					border = "rounded", -- Rounded borders for the floating window if enabled
				},
			})

			vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
			vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show full diagnostic message" })
			vim.keymap.set({ "n", "v" }, "<leader>ca", function()
				require("fzf-lua").lsp_code_actions({ silent = true })
			end, { desc = "Open code actions" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
			vim.keymap.set(
				"n",
				"<leader>fd",
				require("fzf-lua").diagnostics_document,
				{ desc = "Document diagnostics" }
			)
		end,
	},
}
