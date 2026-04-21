return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons

		config = function()
			require("render-markdown").setup({
				on = {
					attach = function()
						vim.treesitter.start()
					end,
				},
			})
			local keymap = vim.keymap.set

			keymap("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown Render" })
		end,
	},
	{
		"dhruvasagar/vim-table-mode",
		init = function()
			-- 1. This kills the default <leader>tm and others
			vim.g.table_mode_disable_mappings = 1
			-- 2. This prevents it from taking over other table keys
			vim.g.table_mode_disable_tableize_mappings = 1
			-- 3. Standard Markdown behavior
			vim.g.table_mode_syntax = 0
		end,
		config = function()
			local keymap = vim.keymap.set

			keymap("n", "<leader>tt", "<cmd>TableModeToggle<CR>", { desc = "Toggle Table Mode" })
		end,
	},
}
