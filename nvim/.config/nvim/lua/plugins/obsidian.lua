return {
	{
		"obsidian-nvim/obsidian.nvim",
		ft = "markdown",
		opts = {
			legacy_commands = false,
			workspaces = {
				{
					name = "personal",
					path = "~/Library/CloudStorage/ProtonDrive-mattis.brandsoy@pm.me-folder/Documents/Obsidian/private_vault",
				},
				{
					name = "work",
					path = "~/Library/CloudStorage/ProtonDrive-mattis.brandsoy@pm.me-folder/Documents/Obsidian/work_vault",
				},
			},
			-- Set assets folder for images
			attachments = {
				img_folder = "/assets", -- Uses vault root /assets
			},
		},
	},
	{
		"folke/snacks.nvim",
		opts = {
			image = {
				enabled = true,
				doc = { enabled = true, inline = true },
				resolve = function(path, src)
					if require("obsidian.api").path_is_note(path) then
						return require("obsidian.api").resolve_image_path(src)
					end
				end,
			},
		},
	},
}
