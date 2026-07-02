return {
	"nvim-telescope/telescope.nvim",
	-- `master`, not the frozen `0.1.x`: 0.1.x calls nvim-treesitter's removed
	-- `ft_to_lang` in its previewer, which crashes now that we're on the
	-- nvim-treesitter `main` branch (Neovim 0.12). master rewrote the previewer
	-- to use native vim.treesitter and requires Neovim 0.11+.
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
		{ "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("live_grep_args")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fo", "<cmd>Telescope buffers<cr>", { desc = "Fuzzy find open buffers" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos comments" })
		keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "Start live grep args" })
	end,
}
