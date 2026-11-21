return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			lsp = {
				signature = {
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true,
					},
					opts = {
						size = {
							max_height = 4, -- Capped at 4 lines
						},
						position = {
							row = 2, -- Keeps it strictly below the line you are typing
							col = 0,
						},
					},
				},
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		})

		-- Scroll signature and hover documentation with <C-d> / <C-u>:
		vim.keymap.set({ "n", "i", "s" }, "<C-d>", function()
			if not require("noice.lsp").scroll(4) then
				return "<C-d>"
			end
		end, { silent = true, expr = true, desc = "Scroll doc down" })

		vim.keymap.set({ "n", "i", "s" }, "<C-u>", function()
			if not require("noice.lsp").scroll(-4) then
				return "<C-u>"
			end
		end, { silent = true, expr = true, desc = "Scroll doc up" })

		-- Navigate cmdline popup completion (and history) with Down / Up:
		vim.keymap.set("c", "<Down>", "<C-n>", { desc = "Next completion / history" })
		vim.keymap.set("c", "<Up>", "<C-p>", { desc = "Prev completion / history" })
	end,
}
