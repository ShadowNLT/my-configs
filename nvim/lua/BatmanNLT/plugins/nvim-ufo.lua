return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async", -- required by ufo
	},
	event = "BufReadPost",
	config = function()
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { "treesitter", "indent" }
			end,
		})

		-- Keybindings for folding
		local map = vim.keymap.set
		map("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds (ufo)" })
		map("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds (ufo)" })
		map("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds (ufo)" })
		map("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level (ufo)" })
	end,
}
