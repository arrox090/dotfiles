return {
	"vim-test/vim-test",
	dependencies = {
		"preservim/vimux",
	},
	vim.keymap.set("n", "<leader>t", ":TestNearest<CR>"),
	vim.keymap.set("n", "<leader>T", ":TestFile<CR>"),
	-- keymap('n', '<leader>a', ':TestSuite<CR>'),
	-- keymap('n', '<leader>l', ':TestLast<CR>'),
	-- keymap('n', '<leader>g', ':TestVisit<CR>'),

	vim.cmd("let test#strategy = 'vimux'"),
}
