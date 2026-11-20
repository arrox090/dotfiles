return {
	"vim-test/vim-test",
	dependencies = {
		"preservim/vimux",
	},
	-- vim.keymap.set("n", "<leader>t", ":TestNearest<CR>"),
	vim.keymap.set("n", "<leader>T", ":TestFile<CR>"),
	-- keymap('n', '<leader>a', ':TestSuite<CR>'),
	-- keymap('n', '<leader>l', ':TestLast<CR>'),
	-- keymap('n', '<leader>g', ':TestVisit<CR>'),

	-- Send test execution commands to a bottom Tmux pane via vimux
	vim.cmd("let test#strategy = 'vimux'"),
}
