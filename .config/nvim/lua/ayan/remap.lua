vim.g.mapleader = " "

----------------------
---- Project view ----
----------------------
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

--------------------------
---- Screen scrolling ----
--------------------------
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<M-d>", "<PageDown>")
vim.keymap.set("n", "<M-u>", "<PageUp>")
vim.keymap.set("n", "G", "Gzz")

------------------
---- Obsidian ----
------------------
vim.keymap.set("n", "<leader>od", ":ObsidianToday ")
vim.keymap.set("n", "<leader>ob", ":ObsidianBacklinks<CR>")
vim.keymap.set("n", "<leader>os", ":ObsidianSearch ")
vim.keymap.set("n", "<leader>ot", ":ObsidianTags ")
vim.keymap.set("n", "<leader>oz", ":ObsidianNew<CR>")
vim.keymap.set("n", "<leader>tw", ":set textwidth=80")
vim.keymap.set("i", "<C-d>", "<ESC>!!tod<CR>o")

-------------------
---- Telescope ----
-------------------
-- I have no idea why the following kepmaps won't work when set in the Telescope
-- config file in /after/plugin/telescope.lua
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>gg", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

--------------------------
---- Split navigation ----
--------------------------
local resize_jump = 4
vim.keymap.set("n", "<leader>h", vim.cmd.sp) -- create horizontal split
vim.keymap.set("n", "<leader>v", vim.cmd.vs) -- create vertical split
vim.keymap.set("n", "<C-Left>" , resize_jump.."<C-w><")
vim.keymap.set("n", "<C-Right>", resize_jump.."<C-w>>")
vim.keymap.set("n", "<C-Up>"   , resize_jump.."<C-w>+")
vim.keymap.set("n", "<C-Down>" , resize_jump.."<C-w>-")
vim.keymap.set("n", "<C-h>", "<C-w>h") -- shift focus to buffer on right
vim.keymap.set("n", "<C-j>", "<C-w>j") -- shift focus to buffer on below
vim.keymap.set("n", "<C-k>", "<C-w>k") -- shift focus to buffer on above
vim.keymap.set("n", "<C-l>", "<C-w>l") -- shift focus to buffer on left
vim.keymap.set("n", "<C-c>", "<C-w>c") -- close current buffer
