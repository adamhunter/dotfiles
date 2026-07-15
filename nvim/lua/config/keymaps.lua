local map = vim.keymap.set

-- Ctrl-L recolors the screen
map("n", "<C-l>", "<C-l>:syntax sync fromstart<CR>", { silent = true })
map("i", "<C-l>", "<Esc><C-l>:syntax sync fromstart<CR>a", { silent = true })

-- Enter clears search highlight
map("n", "<CR>", ":nohlsearch<CR>/<BS>", { silent = true })
map("n", "<C-CR>", ":nohlsearch<CR>/<BS>", { silent = true })

-- Visual mode indenting (stay in visual mode)
map("v", ">", ">gv")
map("v", "<Tab>", ">gv")
map("v", "<", "<gv")
map("v", "<S-Tab>", "<gv")

-- Shift-tab in insert mode is backspace
map("i", "<S-Tab>", "<BS>")

-- Control+h produces a hashrocket
map("i", "<C-h>", " => ")

-- Move lines up and down
map("n", "<C-J>", ":m +1<CR>", { silent = true })
map("n", "<C-K>", ":m -2<CR>", { silent = true })

-- Duplicate a selection
map("v", "D", "y'>p")

-- Select last edited/pasted text
map("n", "gV", "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Insert path of current file in command mode
map("c", "<C-P>", "<C-R>=expand('%:p:h') . '/'<CR>")
