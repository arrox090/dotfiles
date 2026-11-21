return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"jay-babu/mason-nvim-dap.nvim",
			"Weissle/persistent-breakpoints.nvim",
		},
		config = function()
			local dap = require("dap")

			require("mason-nvim-dap").setup({
				ensure_installed = { "debugpy" },
				automatic_setup = true,
				handlers = {},
			})

			require("persistent-breakpoints").setup({
				load_breakpoints_event = { "BufReadPost" },
			})

			dap.adapters.docker = {
				type = "server",
				host = "127.0.0.1",
				port = 5678,
			}

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						if vim.env.VIRTUAL_ENV then
							return vim.env.VIRTUAL_ENV .. "/bin/python"
						end
						return "/usr/bin/python3"
					end,
				},
				{
					type = "python",
					request = "launch",
					name = "Launch Flask",
					module = "flask",
					args = { "run", "--no-debugger", "--no-reload" },
					env = { FLASK_APP = "${file}" },
					pythonPath = function()
						if vim.env.VIRTUAL_ENV then
							return vim.env.VIRTUAL_ENV .. "/bin/python"
						end
						return "/usr/bin/python3"
					end,
				},
				{
					type = "docker",
					request = "attach",
					name = "Attach Docker (Erasmus/Django)",
					pathMappings = {
						{ localRoot = vim.fn.getcwd() .. "/oms", remoteRoot = "/home/app/web" },
					},
				},
			}

			vim.fn.sign_define("DapBreakpoint", { text = "\u{f111}", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapStopped", { text = "\u{f0a9}", texthl = "DiagnosticInfo" })

			local keymap = vim.keymap.set
			local pb = require("persistent-breakpoints.api")

			keymap("n", "<leader>db", pb.toggle_breakpoint, { desc = "Toggle breakpoint" })
			keymap("n", "<leader>dB", pb.clear_all_breakpoints, { desc = "Clear all breakpoints" })
			keymap("n", "<leader>dc", function()
				if dap.session() then
					dap.continue()
					return
				end

				local configs = dap.configurations[vim.bo.filetype] or {}
				if #configs == 0 then
					vim.notify("No DAP configurations for " .. vim.bo.filetype, vim.log.levels.WARN)
					return
				end

				local names = {}
				for _, c in ipairs(configs) do
					table.insert(names, c.name)
				end

				require("fzf-lua").fzf_exec(names, {
					prompt = "DAP (" .. vim.bo.filetype .. ")> ",
					winopts = { height = 0.35, width = 0.5 },
					actions = {
						["default"] = function(selected)
							local choice = selected[1]
							for _, c in ipairs(configs) do
								if c.name == choice then
									dap.run(c)
									break
								end
							end
						end,
					},
				})
			end, { desc = "Start/continue debugging" })
			keymap("n", "<leader>do", dap.step_over, { desc = "Step over" })
			keymap("n", "<leader>di", dap.step_into, { desc = "Step into" })
			keymap("n", "<leader>dO", dap.step_out, { desc = "Step out" })
			keymap("n", "<leader>dt", dap.terminate, { desc = "Terminate session" })
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-dap-virtual-text").setup({
				highlight_changed_variables = true, -- highlight variables that changed value
				highlight_new_as_changed = true,
			})
		end,
	},
}
