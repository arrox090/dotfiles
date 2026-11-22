return {
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"nvimtools/none-ls.nvim",
			"nvimtools/none-ls-extras.nvim",
		},
		config = function()
			local null_ls = require("null-ls")

			require("mason-null-ls").setup({
				automatic_installation = false,
				ensure_installed = {
					"ruff", -- Python
					"shfmt", -- Bash
					"stylua", -- Lua
					"google-java-format", -- Java
					"checkstyle", -- Java linter
					"prettier", -- Markdown, HTML, YAML
					"sql-formatter", -- SQL
				},
				handlers = {
					-- Prevent Prettier from fighting Biome over JSON:
					prettier = function()
						null_ls.register(null_ls.builtins.formatting.prettier.with({
							filetypes = { "markdown", "html", "css", "yaml" },
						}))
					end,

					-- Configure shfmt for zsh
					shfmt = function()
						null_ls.register(null_ls.builtins.formatting.shfmt.with({
							filetypes = { "bash", "sh", "zsh" },
						}))
					end,
				},
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
					-- Use built-in zsh -n linter:
					null_ls.builtins.diagnostics.zsh,

					-- Security & bug diagnostics on save (disable semgrep for python)
					null_ls.builtins.diagnostics.semgrep.with({
						method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
						disabled_filetypes = { "python" },
					}),
				},
			})

			vim.keymap.set("n", "<leader>nf", function()
				vim.lsp.buf.format({
					filter = function(client)
						return client.name ~= "lua_ls"
					end,
				})
			end, { desc = "Format current buffer" })
		end,
	},
}
