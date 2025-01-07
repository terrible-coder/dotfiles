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

-------------------
---- Telescope ----
-------------------
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope grep_string<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")
vim.keymap.set("n", "<leader>fr", ":Telescope lsp_references<CR>")

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

vim.keymap.set(
	{ "i", "s" }, "<C-l>",
	function() require("luasnip").jump( 1) end
)
vim.keymap.set(
	{ "i", "s" }, "<C-h>",
	function() require("luasnip").jump(-1) end
)
