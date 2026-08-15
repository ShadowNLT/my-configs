-- nvim-treesitter-textobjects — language-agnostic function/block navigation.
--
-- Tracks the `main` branch to match nvim-treesitter (the classic `master`
-- keymaps={...} API does not exist here; on `main` you call the select/move
-- module functions yourself, same as our hand-rolled incremental selection).
--
-- Motions (jumplist-aware, so <C-o> returns) — <leader>j = "jump",
-- lowercase = start, uppercase = end:
--   <leader>jf / <leader>jF -> start / end of the function you're inside
--   <leader>jb / <leader>jB -> start / end of the nearest block (if/for body…)
-- Text objects (visual + operator-pending):
--   af / if  -> a / inner function     (e.g. vaf, daf, yif)
--   ab / ib  -> a / inner block        (shadows the builtin () textobject —
--               swap the "ab"/"ib" lhs below back if you want parens instead)
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				-- Jump forward to the textobject if the cursor is before it on the line.
				lookahead = true,
			},
			move = {
				-- Push the pre-jump position onto the jumplist.
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		local function map(modes, lhs, fn, desc)
			vim.keymap.set(modes, lhs, fn, { silent = true, desc = desc })
		end

		-- Select text objects (visual + operator-pending).
		map({ "x", "o" }, "af", function()
			select.select_textobject("@function.outer", "textobjects")
		end, "Select a function")
		map({ "x", "o" }, "if", function()
			select.select_textobject("@function.inner", "textobjects")
		end, "Select inner function")
		map({ "x", "o" }, "ab", function()
			select.select_textobject("@block.outer", "textobjects")
		end, "Select a block")
		map({ "x", "o" }, "ib", function()
			select.select_textobject("@block.inner", "textobjects")
		end, "Select inner block")

		-- Jump to the boundaries of the enclosing function / block.
		-- Inside a node, "previous start" == its start and "next end" == its end.
		map({ "n", "x", "o" }, "<leader>jf", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, "Jump: function start")
		map({ "n", "x", "o" }, "<leader>jF", function()
			move.goto_next_end("@function.outer", "textobjects")
		end, "Jump: function end")
		map({ "n", "x", "o" }, "<leader>jb", function()
			move.goto_previous_start("@block.outer", "textobjects")
		end, "Jump: block start")
		map({ "n", "x", "o" }, "<leader>jB", function()
			move.goto_next_end("@block.outer", "textobjects")
		end, "Jump: block end")
	end,
}
