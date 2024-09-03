local lsp = require("lsp-zero")
lsp.preset("recommended")

local mason = require("mason")
local masonlsp = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason.setup({
	ui = {
		icons = {
			package_installed   = "",
			package_pending     = "",
			package_uninstalled = "",
		},
	},
	pip = {
		upgrade_pip = true,
	}
})

masonlsp.setup({
	ensure_installed = { "lua_ls", },
	handlers = {
		lsp.default_setup,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
			lspconfig.lua_ls.setup(lua_opts)
		end,
		clangd = function()
			lspconfig.clangd.setup({
				default_config = {
					cmd = {
						"gcc",
					}
				}
			})
		end,
	}
})
