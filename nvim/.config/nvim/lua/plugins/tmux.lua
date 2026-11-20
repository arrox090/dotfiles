return {
	-- Seamless navigation between Neovim and Tmux panes
	{
		"christoomey/vim-tmux-navigator",
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left window/pane" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower window/pane" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper window/pane" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right window/pane" },
		},
	},

	-- Send commands directly to Tmux panes/splits from Neovim
	{
		"preservim/vimux",
	},
}
