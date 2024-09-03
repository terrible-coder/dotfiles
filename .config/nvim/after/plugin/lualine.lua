require("lualine").setup({
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
})
