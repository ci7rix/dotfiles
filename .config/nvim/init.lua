-- Rosé Pine, installed without asking by the built-in plugin manager (Neovim 0.12+).
-- "auto" follows 'background', which Neovim reads from the terminal:
-- main when Ghostty is dark, dawn when it is light (same as Ghostty and fish).
vim.pack.add({ { src = "https://github.com/rose-pine/neovim", name = "rose-pine" } }, { confirm = false })
require("rose-pine").setup({ variant = "auto", dark_variant = "main" })
vim.cmd.colorscheme("rose-pine")

-- Editing
local o = vim.opt
o.expandtab = true -- spaces instead of tabs
o.shiftwidth = 2
o.softtabstop = 2
o.shiftround = true
o.number = true
o.cursorline = true
o.splitbelow = true
o.splitright = true
o.list = true
o.listchars = { tab = "▸ ", extends = "❯", precedes = "❮", nbsp = "±" }
o.report = 0 -- always report changed lines
o.synmaxcol = 200
