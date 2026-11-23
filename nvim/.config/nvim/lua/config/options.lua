local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- clipboard
if vim.fn.getenv("WAYLAND_DISPLAY") == vim.NIL then
	if vim.loop.os_uname().sysname ~= "Darwin" then
		local provider = vim.g.clipboard or ""
		if provider == "" or provider:match("tmux") then
			vim.g.clipboard = "osc52"
		end
	end
else
	vim.g.clipboard = "wl-copy"
end

opt.clipboard:append("unnamedplus")

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- Cursor line
opt.cursorline = true

-- backspace
opt.backspace = "indent,eol,start"

-- set min lines/columns that are visable
opt.scrolloff = 5
opt.sidescrolloff = 30

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Disable wrap
opt.wrap = false

-- When wrap on won't cut words in half, and lines will keep the same indentation
opt.linebreak = true
opt.breakindent = true

-- Don't show mode
vim.o.showmode = false

-- tests
-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

-- fold fix for python
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false -- don't fold everything on open
vim.opt.foldlevel = 99

-- make vimux use a tmux pane with 15 lines height
vim.g.VimuxHeight = "15"

-- Python indentation (single shiftwidth on open brackets, so it doesn't put the cursor like 2x further than it should)
vim.g.pyindent_open_paren = "shiftwidth()"
vim.g.pyindent_continue = "shiftwidth()"
