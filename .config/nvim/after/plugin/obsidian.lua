local vaults = "~/documents/notes/"
local obsidian = require("obsidian")

obsidian.setup({
	workspaces = {
		{ name = "Primary", path = vaults.."Primary" }
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
})
