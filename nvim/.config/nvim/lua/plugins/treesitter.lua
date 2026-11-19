return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- Forces Lazy to pull the rewritten, compatible branch
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- Setup no longer accepts the old options table
		require("nvim-treesitter").setup()

		-- Parsers are now installed explicitly via a separate function
		require("nvim-treesitter").install({ "python", "lua", "markdown", "json5" })

		-- THIS replaces the old auto_install = true:
		require("nvim-treesitter").install({
			auto_install = true,
		})

		vim.treesitter.language.register("json5", "jsonc")

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})
	end,
}
