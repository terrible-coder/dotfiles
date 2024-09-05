return require("lazy").setup({
	-- fuzzy file finder
	{
	  "nvim-telescope/telescope.nvim",
		tag = "0.1.5",
	  dependencies = {
	  	"nvim-lua/plenary.nvim"
	  }
	},
	-- colour scheme
	-- { "Mofiqul/dracula.nvim" },
	{ "rose-pine/neovim", name = "rose-pine" },
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons"
		}
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
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
		version = "*",
		lazy = true,
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
})
