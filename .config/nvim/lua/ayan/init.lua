-- This is the entry point for the configuration of neovim as wished for by the
-- user `ayan`. To apply this configuration write the line `require("ayan")` in
-- the nvim config file. To apply someone else's configurations, throw the code
-- in its own directory and require the module accordingly.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git", "clone", "--filter=blob:none", "--branch=stable",
		lazyrepo, lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." }
		}, true, { })
		vim.fn.getchar()
		os.exit(1)
	end
end
-- runtime path now has the lazy repo
vim.opt.rtp:prepend(lazypath)

-- vim.opt.guicursor = ""
vim.g.vim_markdown_conceal = 2
vim.opt.conceallevel = 2

vim.opt.textwidth = 80
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.smartindent = true

-- vim.opt.splitright = true
-- vim.opt.splitbelow = true

vim.opt.nu = true
vim.opt.rnu = true

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt.nu = false
		vim.opt.rnu = false
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight", { }),
	desc = "Highlight when yanking",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 100 })
	end
})

require("ayan.plugins")
vim.cmd.colorscheme("rose-pine")
require("ayan.remap")
