return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		-- supress annoying Legacy Commands warning
		legacy_commands = false,

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
			function()
				require("fzf-lua").files({
					cwd = "~/notes",
					cwd_header = false,
					cwd_prompt = false,
					prompt = "Notes> ",
					hidden = false,
					fd_opts = "--type f --extension md --exclude .obsidian",
				})
			end,
			desc = "Fuzzy find obsidian note",
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
