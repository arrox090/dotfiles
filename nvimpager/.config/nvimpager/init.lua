-- Disable nvimpager's built-in less-like keybindings
nvimpager.maps = false

vim.opt.clipboard = "unnamedplus"

-- Quit like in pagers (just by clicking q)
vim.keymap.set("n", "q", "<cmd>qa!<CR>")

-- Scroll the window with J and K
vim.keymap.set("n", "J", "<C-e>")
vim.keymap.set("n", "K", "<C-y>")
