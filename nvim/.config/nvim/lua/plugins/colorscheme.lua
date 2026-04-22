return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			custom_highlights = function(colors)
				return {
					-- make it a little more distinct from parameter color
					["@variable.builtin"] = { fg = "#e56460", italic = true },

					-- change bold, italic and `` colors in markup
					["@markup.strong.markdown_inline"] = { fg = colors.mauve, bold = true },
					["@markup.italic.markdown_inline"] = { fg = colors.teal, italic = true },
					["@markup.raw.markdown_inline"] = { fg = colors.sapphire, italic = true },

					-- change table and dash colors for render markdown plugin
					RenderMarkdownDash = { fg = colors.teal },
					RenderMarkdownTableHead = { fg = colors.sapphire, bold = true },
					RenderMarkdownTableRow = { fg = colors.teal, bold = true },
				}
			end,
		})

		vim.cmd.colorscheme("catppuccin")

		-- Set colors for line numbers
		vim.cmd("highlight LineNr guifg=#87CEEB guibg=NONE")
		vim.cmd("highlight CursorLineNR guifg=#00FF00 guibg=NONE")
	end,
}
