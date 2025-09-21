local keymap = vim.keymap.set

-- Set leader key early
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Clear search highlights
keymap("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights", noremap = true, silent = true })

-- delete single character withou copying into register
keymap("n", "x", '"_x')

-- center screen after these commands
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- exit insert mode
keymap("i", "jk", "<ESC>")
keymap("t", "jk", "<C-\\><C-n>", { silent = true })

-- insert empty line below
keymap("n", "<CR>", "o<ESC>")

-- Go the the previously open file
keymap("n", "<leader><tab>", "<C-^>", { desc = "Go to previous file" })

-- -- command to enter terminal
-- keymap(
-- 	"n",
-- 	"<leader>ot",
-- 	":split | resize 20 | startinsert | term<CR>",
-- 	{ desc = "Open terminal in split window below", noremap = true }
-- )

-- navitage vim panes
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to below split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to above split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })
