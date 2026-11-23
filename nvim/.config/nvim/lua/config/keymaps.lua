local keymap = vim.keymap.set

-- Set leader key early
vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Clear search highlights
keymap("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlights", noremap = true, silent = true })

-- Toggle text wrapping
keymap("n", "tw", "<cmd>set wrap!<CR>", { desc = "Toggle Text Wrapping" })

-- delete single character withou copying into register
keymap("n", "x", '"_x')

-- center screen after these commands
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- exit insert mode
-- keymap("i", "jk", "<ESC>")
-- keymap("t", "jk", "<C-\\><C-n>", { silent = true })

-- Insert empty line below in code files, but keep native Enter in help, quickfix, and command windows:
keymap("n", "<CR>", function()
	if vim.bo.buftype ~= "" or vim.bo.filetype == "qf" then
		return "<CR>"
	end
	return "o<ESC>"
end, { expr = true, desc = "Insert blank line below" })

-- Disable accidental command history popup when mistyping :q
keymap("n", "q:", "<nop>", { desc = "Disable accidental q: window" })

-- Go the the previously open file
keymap("n", "<leader><tab>", "<C-^>", { desc = "Go to previous file" })

-- navitage vim panes
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to below split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to above split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })

-- Move single line in Normal mode:
keymap("n", "]e", "<cmd>m .+1<CR>==", { desc = "Move line down" })
keymap("n", "[e", "<cmd>m .-2<CR>==", { desc = "Move line up" })

-- Move highlighted block in Visual mode:
keymap("v", "]e", "<esc><cmd>'<,'>m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "[e", "<esc><cmd>'<,'>m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Map U to redo, so its u=undo, U=redo
keymap("n", "U", "<C-r>", { desc = "Redo" })

-- Increment and decrement a number with + and -
vim.keymap.set({ "n", "v" }, "+", "<C-a>", { desc = "Increment number" })
vim.keymap.set({ "n", "v" }, "-", "<C-x>", { desc = "Decrement number" })

-- Handle Option+Backspace (sent by Karabiner Option+Ctrl+O) in Insert mode:
vim.keymap.set("i", "<M-BS>", "<C-w>", { desc = "Delete word backwards" })
