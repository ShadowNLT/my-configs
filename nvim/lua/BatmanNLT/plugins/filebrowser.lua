return {
	"nvim-telescope/telescope-file-browser.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},

	config = function()
		-- load the extension
		require("telescope").load_extension("file_browser")

		-- keymap to open the file browser
		vim.keymap.set("n", "<leader>fb", function()
			require("telescope").extensions.file_browser.file_browser({
				path = "%:p:h",
				cwd = vim.fn.getcwd(),
				respect_gitignore = false,
				hidden = true,
				grouped = true,
			})
		end, { desc = "File Browser" })
	end,
}
