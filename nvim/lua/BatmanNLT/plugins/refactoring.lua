return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},

	config = function()
		local refactoring = require("refactoring")

		-- minimal setup with defaults
		refactoring.setup({})

		-- <leader>R in NORMAL + VISUAL mode → open refactor menu
		vim.keymap.set({ "n", "v" }, "<leader>R", function()
			refactoring.select_refactor()
		end, { desc = "Refactor (select refactor)" })
	end,
}
