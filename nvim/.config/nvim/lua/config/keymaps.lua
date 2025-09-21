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

-- command to enter terminal
keymap(
  "n",
  "<leader>ot",
  ":split | resize 20 | startinsert | term<CR>",
  { desc = "Open terminal in split window below", noremap = true }
)

-- navitage vim panes
keymap("n", "<c-k>", ":wincmd k<CR>", { desc = "Open split up" })
keymap("n", "<c-j>", ":wincmd j<CR>", { desc = "Open split down" })
keymap("n", "<c-h>", ":wincmd h<CR>", { desc = "Open split left" })
keymap("n", "<c-l>", ":wincmd l<CR>", { desc = "Open split right" })
