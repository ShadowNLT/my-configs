vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- Set scroll padding to at least 10 visibles lines above and below the cursor
vim.o.scrolloff = 10
-- Tabs and Identation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth= 2 -- 2 spaces for idnent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting a new one

opt.wrap = false

-- Search Settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- If I include mixed case in my search, the system will assume I want case-sensitive

-- Highlight the current line where the cursor is
opt.cursorline = true

-- Turn on termguicolors
-- Works for true color terminals
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- Show sign column so that text doesn't shit

-- Backspace
opt.backspace = "indent,eol,start" -- Allow Backspace on indent, end of line or insert mode start position

-- Clipboard
opt.clipboard:append("unnamedplus") -- Use system clipboard as default register

-- Split Windows
opt.splitright = true -- When splitting a window, the original window will go to the right
opt.splitbelow = true -- When splitting a window, the original window will go to the bottom
