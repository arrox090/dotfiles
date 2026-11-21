return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local actions = require("fzf-lua.actions")
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
				keymap = {
					builtin = {
						-- Scroll the preview window with Ctrl+d / Ctrl+u:
						["<C-d>"] = "preview-page-down",
						["<C-u>"] = "preview-page-up",
					},
				},
				actions = {
					files = {
						["enter"] = actions.file_edit_or_qf,
						["ctrl-r"] = { fn = actions.toggle_hidden, reuse = true, header = false },
					},
					grep = {
						["enter"] = actions.file_edit_or_qf,
						["ctrl-r"] = { fn = actions.toggle_hidden, reuse = true, header = false },
					},
				},
			})

			vim.keymap.set("n", "<leader>ff", function()
				FzfLua.files({ cwd = vim.fn.expand("%:p:h") })
			end, { desc = "Fuzzy find files" })
			vim.keymap.set("n", "<leader>fs", FzfLua.live_grep, { desc = "Fuzzy find string" })
			vim.keymap.set("n", "<leader>fk", FzfLua.keymaps, { desc = "Fuzzy find keymaps" })
			vim.keymap.set("n", "<leader>fb", FzfLua.buffers, { desc = "Fuzzy find buffers" })
			vim.keymap.set(
				"n",
				"<leader>fm",
				FzfLua.lsp_document_symbols,
				{ desc = "Fuzzy find methods & symbols in file" }
			)
			vim.keymap.set(
				"n",
				"<leader>fg",
				FzfLua.files,
				{ desc = "Fuzzy find files from the dir neovim was started" }
			)
			vim.keymap.set("n", "<leader>fn", function()
				FzfLua.files({
					cwd = vim.fn.stdpath("config"),
					cwd_header = false,
					cwd_prompt = false,
					prompt = "Neovim> ",
				})
			end, { desc = "Fuzzy find files in nvim config directory" })
			vim.keymap.set("n", "<leader>fh", function()
				FzfLua.files({
					cwd = vim.fn.expand("~"),
					cwd_header = false,
					cwd_prompt = false,
					prompt = "Home> ",
				})
			end, { desc = "Fuzzy find files in home directory" })
		end,
	},
}
