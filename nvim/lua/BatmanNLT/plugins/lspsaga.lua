return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("lspsaga").setup({
			ui = {
				border = "rounded",
				winblend = 0,
			},
			-- Winbar breadcrumb: file path + code symbols.
			-- folder_level = how many parent dirs to show before the filename.
			symbol_in_winbar = {
				enable = true,
				folder_level = 4,
			},
			lightbulb = {
				enable = true,
				sign = true,
				virtual_text = true,
			},
		})
	end,
}
