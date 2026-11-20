return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		-- Disable automatic frontmatter (stops adding unwanted IDs at the top of notes on save)
		frontmatter = {
			enabled = false,
		},
		workspaces = {
			{
				name = "notes",
				path = "~/notes",
			},
		},
	},
	keys = {
		{
			"<leader>fo",
			"<cmd>Obsidian quick_switch<cr>",
			desc = "Find obsidian note",
		},
		{
			"<leader>ob",
			"<cmd>Obsidian backlinks<cr>",
			desc = "Backlinks",
		},
		{
			"<leader>op",
			"<cmd>Obsidian paste_img<cr>",
			desc = "Paste image",
		},
		{
			"<leader>or",
			"<cmd>Obsidian rename<cr>",
			desc = "Rename note",
		},
	},
}
