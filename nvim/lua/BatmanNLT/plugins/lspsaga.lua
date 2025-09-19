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
			lightbulb = {
				enable = true,
				sign = true,
				virtual_text = true,
			},
		})
	end,
}
