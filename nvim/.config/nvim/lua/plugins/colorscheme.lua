return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			transparent_background = true,
			custom_highlights = function(colors)
				return {
					-- Headings
					RenderMarkdownH1 = { fg = colors.mauve, bold = true },
					RenderMarkdownH2 = { fg = colors.lavender, bold = true },
					RenderMarkdownH3 = { fg = colors.sapphire, bold = true },
					RenderMarkdownH4 = { fg = colors.teal, bold = true },
					RenderMarkdownH5 = { fg = colors.sky, bold = true },
					RenderMarkdownH6 = { fg = colors.blue, bold = true },
					-- Heading backgrounds
					RenderMarkdownH1Bg = { bg = colors.surface0 },
					RenderMarkdownH2Bg = { bg = colors.surface0 },
					RenderMarkdownH3Bg = { bg = colors.surface0 },
					-- Tables
					RenderMarkdownTableHead = { fg = colors.lavender, bold = true },
					RenderMarkdownTableRow = { fg = colors.text },
					-- Code
					RenderMarkdownCode = { bg = colors.surface0 },
					RenderMarkdownCodeInline = { fg = colors.teal, bg = colors.surface0 },
					-- Bullets & checkboxes
					RenderMarkdownBullet = { fg = colors.mauve },
					RenderMarkdownChecked = { fg = colors.teal },
					RenderMarkdownUnchecked = { fg = colors.overlay1 },
					-- Quotes & links
					RenderMarkdownQuote = { fg = colors.overlay2, italic = true },
					RenderMarkdownLink = { fg = colors.blue },
					-- Bold & italic (treesitter)
					["@markup.strong.markdown_inline"] = { fg = colors.mauve, bold = true },
					["@markup.italic.markdown_inline"] = { fg = colors.lavender, italic = true },
				}
			end,
		})

		vim.cmd.colorscheme("catppuccin")

		-- Set colors for line numbers
		vim.cmd("highlight LineNr guifg=#87CEEB guibg=NONE")
		vim.cmd("highlight CursorLineNR guifg=#00FF00 guibg=NONE")
	end,
}
