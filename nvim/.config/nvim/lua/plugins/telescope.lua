return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"andrew-george/telescope-themes",
		},
		config = function()
			local builtin_schemes = require("telescope._extensions.themes").builtin_schemes
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					layout_config = {
						horizontal = {
							width = 0.95,
							height = 0.9,
							preview_width = 0.7,
						},
					},
					enable_previewer = true,
					enable_live_preview = false,
					persist = { enabled = true },
				},
			})

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>en", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Telescope live grep" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
