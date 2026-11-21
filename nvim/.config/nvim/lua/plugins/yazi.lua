return {
	"mikavilpas/yazi.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>ee",
			"<cmd>Yazi<cr>",
			desc = "Open yazi",
		},
		{
			"<leader>eg",
			"<cmd>Yazi cwd<cr>",
			desc = "Open yazi from the dir neovim was started",
		},
	},
	opts = {
		open_for_directories = true,

		keymaps = false,
		--   {
		-- 	-- show_help = "<f1>",
		-- 	-- open_file_in_vertical_split = "<c-v>",
		-- 	-- open_file_in_horizontal_split = "<c-x>",
		-- 	-- open_file_in_tab = "<c-t>",
		-- 	-- grep_in_directory = "<c-s>",
		-- 	replace_in_directory = "<c-g>",
		-- 	cycle_open_buffers = "<tab>",
		-- 	copy_relative_path_to_selected_files = "<c-y>",
		-- 	send_to_quickfix_list = "<c-q>",
		-- },
	},
}
