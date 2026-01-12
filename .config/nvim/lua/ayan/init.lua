vim.opt.number = true
vim.opt.relativenumber = true
-- vim.opt.signcolumn = "no"

vim.opt.syntax = "enable"
vim.opt.textwidth = 80
vim.opt.wrap = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.cursorline = true
vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.termguicolors = true
vim.opt.winborder = "single"

vim.opt.conceallevel = 0
vim.g.markdown_fenced_languages = { "bash", "lua" }

vim.lsp.enable({ "lua_ls", "clangd" })
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, {
				autotrigger = true
			})
		end
	end
})

vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json")
				or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
				then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend(
				"force",
				client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
						},
					},
				-- Make the server aware of Neovim runtime files
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						'${3rd}/luv/library'
						-- '${3rd}/busted/library'
					}
					}
				})
			end,
			settings = {
				Lua = { }
			}
})
-- vim.cmd[[set completeopt=menuone,noinsert,noselect,popup,preview]]
vim.opt.completeopt = { "menuone", "noinsert", "noselect", "popup", "preview" }

vim.cmd.packadd("rose-pine")
-- configuring the colourscheme
require("rose-pine").setup({
	styles = {
		bold = true,
		italic = false,
		transparency = false
	},
	groups = {
		h1 = "iris",
		h2 = "iris",
		h3 = "iris",
		h4 = "iris",
		h5 = "iris",
		h6 = "iris",
	},
	highlight_groups = {
		StatusLine = { fg = "surface", bg = "text" },
		PmenuSel = { fg = "surface", bg = "foam" },
	},
	palette = {
		main = {
			text = "#e0e0e0"
		}
	}
})
vim.cmd.colorscheme("rose-pine")

vim.cmd.packadd("gorbanyov-info")

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>r", ":so ~/.config/nvim/init.lua")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")

local highlight_group = vim.api.nvim_create_augroup("highlight", { })
vim.api.nvim_create_autocmd({"TextYankPost"}, {
	group = highlight_group,
	callback = function()
		vim.highlight.on_yank({ timeout = 100 })
	end
})

local yq = require("ayan.yq")

vim.api.nvim_create_user_command("YqKeyword", yq.searchKeyword, {
	nargs = '*',
	complete = "file_in_path"
})
