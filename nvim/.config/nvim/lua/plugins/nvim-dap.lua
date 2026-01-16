return {
	"mfussenegger/nvim-dap",
	dependencies = { "jay-babu/mason-nvim-dap.nvim" },
	config = function()
		local dap = require("dap")
		vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})

		dap.configurations.cpp = {
			{
				type = "codelldb",
				request = "launch",
				name = "Launch file",
				program = "${file}",
			},
		}
	end,
}
