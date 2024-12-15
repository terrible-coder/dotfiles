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
	{ "Mofiqul/dracula.nvim" },
	{ "rose-pine/neovim", name = "rose-pine" },
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
		version = false,
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		opts = {
			ensure_installed = { "bash", "c", "lua", "vim", },
			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
				-- disable = { "markdown" },
				additional_vim_regex_highlighting = false,
			},
		}
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
		}
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
