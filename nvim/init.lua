-- Leader keys must be set before lazy.nvim loads
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim
require("config.lazy")

-- Core settings
require("config.options")
require("config.keymaps")
