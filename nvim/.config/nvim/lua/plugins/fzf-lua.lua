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

			vim.keymap.set("n", "<leader>ff", function()
				FzfLua.files({ cwd = vim.fn.expand("%:p:h") })
			end, { desc = "Fuzzy find files" })
			vim.keymap.set("n", "<leader>fs", FzfLua.live_grep, { desc = "Fuzzy find string" })
			vim.keymap.set(
				"n",
				"<leader>fg",
				FzfLua.files,
				{ desc = "Fuzzy find files from the dir neovim was started" }
			)
			vim.keymap.set("n", "<leader>fn", function()
				FzfLua.files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "Fuzzy find files in nvim config directory" })
			vim.keymap.set("n", "<leader>fh", function()
				FzfLua.files({ cwd = vim.fn.expand("~") })
			end, { desc = "Fuzzy find files in home directory" })
		end,
	},
}
