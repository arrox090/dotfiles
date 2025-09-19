return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local function python_env()
			local conda_env = vim.fn.getenv("CONDA_DEFAULT_ENV")
			if conda_env ~= "" then
				local icon = require("nvim-web-devicons").get_icon("py", { default = true })
				return conda_env .. " " .. icon
			end
			return nil
		end

		local colors = {
			blue = "#65D1FF",
			green = "#3EFFDC",
			violet = "#FF61EF",
			yellow = "#FFDA7B",
			red = "#FF4A4A",
			fg = "#c3ccdc",
			bg = "#112638",
			inactive_bg = "#2c3043",
			semilightgray = "#6e7081", -- Fallback color
		}

		-- Define custom lualine theme
		local my_lualine_theme = {
			normal = {
				a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			insert = {
				a = { bg = colors.green, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			visual = {
				a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			command = {
				a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			replace = {
				a = { bg = colors.red, fg = colors.bg, gui = "bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
			},
			inactive = {
				a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
				b = { bg = colors.inactive_bg, fg = colors.fg },
				c = { bg = colors.inactive_bg, fg = colors.fg },
			},
		}

		-- Setup lualine with dynamic sections and improved features
		lualine.setup({
			options = {
				theme = my_lualine_theme,
				icons_enabled = true,
				disabled_filetypes = {
					statusline = { "NvimTree" }, -- Don't show lualine in NvimTree window
				},
			},
			sections = {
				lualine_b = {
					"branch", -- Show Git branch
					"diff", -- Optional: Show Git diffs (added/removed)
				},
				lualine_c = {
					{ "filename", path = 1 }, -- Shorten file path
					"diagnostics", -- Show diagnostics (LSP errors/warnings)
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "filetype" },
				},
				lualine_y = {
					{
						python_env,
						cond = function()
							return vim.bo.filetype == "python"
						end,
						color = { fg = "#80E1FF" },
						-- Show Python environment (only if Python is available)},
					},
				},
			},
		})
	end,
}
