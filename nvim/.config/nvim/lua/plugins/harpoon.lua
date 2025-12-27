return {
	"ThePrimeagen/harpoon",

	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")
		vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "Add file to harpoon" })
		vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu, { desc = "Open harpoon menu" })
		vim.keymap.set("n", "<leader>h1", function()
			ui.nav_file(1)
		end, { desc = "Open first file from harpoon menu" })
		vim.keymap.set("n", "<leader>h2", function()
			ui.nav_file(2)
		end, { desc = "Open second file from harpoon menu" })
		vim.keymap.set("n", "<leader>h3", function()
			ui.nav_file(3)
		end, { desc = "Open third file from harpoon menu" })
		vim.keymap.set("n", "<leader>h4", function()
			ui.nav_file(4)
		end, { desc = "Open fourth file from harpoon menu" })
		vim.keymap.set("n", "<leader>h5", function()
			ui.nav_file(5)
		end, { desc = "Open fifth file from harpoon menu" })
	end,
}
