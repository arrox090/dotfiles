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

			vim.keymap.set("n", "<leader>ff", function()
				my_telescope_search("find_files")
			end, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fs", function()
				my_telescope_search("live_grep")
			end, { desc = "Telescope find string" })
			vim.keymap.set("n", "<leader>fn", function()
				my_telescope_search("find_files", { cwd = vim.fn.stdpath("config") })
			end, { desc = "Telescope find files in nvim config directory" })
			vim.keymap.set("n", "<leader>fh", function()
				my_telescope_search("find_files", { cwd = vim.fn.expand("~") })
			end, { desc = "Telescope find files in home directory" })
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
