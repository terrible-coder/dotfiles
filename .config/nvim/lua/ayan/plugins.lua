return require("lazy").setup({
	-- fuzzy file finder
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim"
		},
		opts = {
			pickers = {
				find_files = {
					prompt_title = "Search files ("..vim.fn.getcwd()..")"
				},
				grep_string = {
					prompt_title = "Search word ("..vim.fn.getcwd()..")"
				},
				live_grep = {
					prompt_title = "Grep search ("..vim.fn.getcwd()..")"
				}
			},
		}
	},
	-- colour scheme
	{
		"Mofiqul/dracula.nvim",
		lazy = true,
	},
	{
		"rose-pine/neovim", name = "rose-pine",
		lazy = true,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		},
		opts = {
			options = {
				component_separators = "|",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_c = {
					{
						"filename",
						file_status = true, newfile_status = true,
						path = 1,
					},
				},
			}
		}
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		version = "*",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = { "bash", "c", "lua", "vim", },
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					disable = function(lang, buf)
						if lang == "markdown" then
							return true
						end
						local MAX_SIZE = 200 * 1024; -- 200kB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > MAX_SIZE then
							return true
						end
						return false
					end,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},

	-- LSP
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		dependencies = {
			-- LSP Support
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local lsp = require("lsp-zero")
			local lspconfig = require("lspconfig")

			require("mason").setup({
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
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", },
				handlers = {
					lsp.default_setup,
					lua_ls = function()
						lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
					end,
					clangd = function()
						lspconfig.clangd.setup({ })
					end,
				}
			})
		end,
	},

	-- Markdown sweetness
	-- "ixru/nvim-markdown"

	-- Work with Obsidian vaults directly from neovim
	{
		"epwalsh/obsidian.nvim",
		enabled = false,
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			workspaces = {
				{ name = "Primary", path = "~/documents/notes/Primary" }
			},
			notes_subdir = "Zettelkasten",
			daily_notes = {
				folder = "Journal",
				date_format = "%Y-%m-%d",
			},
			preferred_link_style = "wiki",
			new_notes_location = "notes_subdir",
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			disable_frontmatter = false,
			ui = {
				enable = true,
				checkboxes = {
					[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
					["x"] = { char = "", hl_group = "ObsidianDone" },
					[">"] = { char = "", hl_group = "ObsidianRightArrow" },
					["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
				},
			}
		}
	},
})
