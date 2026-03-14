local opt = vim.opt

-- Leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Encoding
opt.encoding = "utf-8"

-- No swap files
opt.swapfile = false
opt.directory = vim.fn.expand("~/.vim_swap") .. ",~/tmp,/var/tmp"
opt.backupdir = vim.fn.expand("~/.vim_backup") .. ",~/tmp,/var/tmp"

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 15
opt.sidescroll = 1

-- Splitting
opt.splitright = true
opt.splitbelow = true

-- Searching
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Tabs (2 spaces)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true

-- Display
opt.number = true
opt.textwidth = 78
opt.termguicolors = true
opt.background = "dark"
opt.guicursor = "i:block"
opt.timeoutlen = 1000
opt.ttimeoutlen = 0

-- Hidden characters
opt.listchars = { trail = "⋅", tab = "▸ ", eol = "¬", extends = "❯", precedes = "❮" }
