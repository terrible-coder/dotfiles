vim.g.mapleader = " "

---------------------------------
---- Project file management ----
---------------------------------
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pd", function()
	vim.ui.input({
		prompt = "Delete file? (y/n) ",
		default = "y",
	},
	function(input)
		if input and input == "y" then
			vim.fn.delete(vim.fn.expand("%"))
		end
	end)
end)

--------------------------
---- Screen scrolling ----
--------------------------
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<M-d>", "<PageDown>")
vim.keymap.set("n", "<M-u>", "<PageUp>")
vim.keymap.set("n", "G", "Gzz")

-------------------
---- Telescope ----
-------------------
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>fw", ":Telescope grep_string<CR>")
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")
vim.keymap.set("n", "<leader>fr", ":Telescope lsp_references<CR>")
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")

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

vim.keymap.set(
	{ "i", "s" }, "<C-l>",
	function() require("luasnip").jump( 1) end
)
vim.keymap.set(
	{ "i", "s" }, "<C-h>",
	function() require("luasnip").jump(-1) end
)
