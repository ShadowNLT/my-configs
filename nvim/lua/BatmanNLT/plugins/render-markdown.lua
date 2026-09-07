return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		-- Plugin disables a couple of treesitter conceal patterns on first
		-- attach; restart so buffers don't keep a half-dead highlighter
		-- (monochrome markdown while Telescope preview still looks fine).
		restart_highlighter = true,
	},
}
