return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter")
		config.setup({
			ensure_installed = { "python", "lua" },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
