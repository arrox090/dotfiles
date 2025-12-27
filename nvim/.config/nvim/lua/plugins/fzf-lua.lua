return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({
				winopts = {
					on_create = function()
						vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
					end,
					height = 0.9,
					width = 0.95,
					treesitter = {
						enabled = true,
					},
					preview = {
						layout = "horizontal",
						horizontal = "right:70%",
					},
				},
			})

			vim.keymap.set("n", "<leader>ff", FzfLua.files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fs", FzfLua.live_grep, { desc = "Telescope find string" })
			vim.keymap.set("n", "<leader>fn", function()
				FzfLua.files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Telescope find files in nvim config directory" })
			vim.keymap.set("n", "<leader>fh", function()
				FzfLua.files({ cwd = vim.fn.expand("~") })
			end, { desc = "Telescope find files in home directory" })
		end,
	},
}
