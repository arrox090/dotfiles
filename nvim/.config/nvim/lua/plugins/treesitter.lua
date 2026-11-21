return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- Forces Lazy to pull the rewritten, compatible branch
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"python",
				"lua",
				"markdown",
				"json5",
				"cpp",
				"c_sharp",
				"java",
				"bash",
				"yaml",
				"sql",
			})

			vim.treesitter.language.register("json5", "jsonc")

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},

	-- Sticky Scroll: pins the function / class header to the top of the screen
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			max_lines = 3, -- Pin up to 3 lines (e.g. class + function)
			trim_scope = "outer",
		},
	},
}
