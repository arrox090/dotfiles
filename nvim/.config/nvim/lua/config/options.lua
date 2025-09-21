local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- clipboard
if vim.fn.getenv("WAYLAND_DISPLAY") == vim.NIL then
  local provider = vim.g.clipboard or ""
  if provider == "" or provider:match("tmux") then
    vim.g.clipboard = "osc52"
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

-- Don't show mode
vim.o.showmode = false
