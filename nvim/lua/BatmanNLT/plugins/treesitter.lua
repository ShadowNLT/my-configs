return {
	"nvim-treesitter/nvim-treesitter",
	-- Neovim 0.12+ is ONLY supported by the `main` rewrite. The old `master`
	-- branch (classic nvim-treesitter.configs API) explicitly supports Neovim
	-- 0.10–0.11 and crashes on 0.12 (highlighter -> "attempt to call method
	-- 'range' (a nil value)"). Homebrew ships 0.12 as stable, so we track `main`.
	branch = "main",
	lazy = false, -- the `main` branch does not support lazy-loading
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- The `main` branch stores bundled queries under runtime/queries/ rather than
		-- queries/ directly. Prepend runtime/ so Neovim's treesitter finds them without
		-- needing a separate TSInstall step.
		vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime")

		local parsers = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"jsdoc",
			"yaml",
			"html",
			"css",
			"scss",
			"sql",
			"prisma",
			"markdown",
			"markdown_inline",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"go",
		}

		-- Install/update parsers (async no-op if already present).
		require("nvim-treesitter").install(parsers)

		--------------------------------------------------------------------------
		-- Incremental selection
		--
		-- The `main` branch dropped the incremental_selection module, so the two
		-- keymaps used here are reimplemented on Neovim's native treesitter API:
		--   <C-space> (visual) grows the selection to the parent named node
		--   <bs>      (visual) shrinks it back to the previous node
		-- Every handler is pcall-wrapped, so a failure can never do worse than
		-- leaving the selection untouched.
		--------------------------------------------------------------------------
		local sel = {} -- bufnr -> stack of TSNode (innermost .. outermost)

		local function root_node_for_range(sr, sc, er, ec)
			local ok, parser = pcall(vim.treesitter.get_parser)
			if not ok or not parser then
				return nil
			end
			local trees = parser:parse()
			local tree = trees and trees[1]
			if not tree then
				return nil
			end
			return tree:root():named_descendant_for_range(sr, sc, er, ec)
		end

		-- Select a node's range in charwise visual mode. TSNode ranges are
		-- 0-indexed with an exclusive end column.
		local function select_node(node)
			if not node then
				return
			end
			local sr, sc, er, ec = node:range()
			if ec == 0 and er > sr then
				-- End sits at the start of a line: pull back to the previous line.
				er = er - 1
				ec = #(vim.api.nvim_buf_get_lines(0, er, er + 1, true)[1] or "")
			end
			vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
			-- '> is 1-indexed inclusive, which equals the exclusive 0-indexed end col.
			vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
			vim.cmd("normal! gv")
		end

		-- Current visual selection as a 0-indexed, end-exclusive range.
		local function visual_range()
			local _, sr, sc = unpack(vim.fn.getpos("v"))
			local _, er, ec = unpack(vim.fn.getpos("."))
			if sr > er or (sr == er and sc > ec) then
				sr, sc, er, ec = er, ec, sr, sc
			end
			return sr - 1, sc - 1, er - 1, ec
		end

		local function node_matches_selection(node)
			if not node then
				return false
			end
			local nsr, nsc, ner, nec = node:range()
			local sr, sc, er, ec = visual_range()
			return nsr == sr and nsc == sc and ner == er and nec == ec
		end

		local function init_selection()
			local buf = vim.api.nvim_get_current_buf()
			local node = vim.treesitter.get_node()
			if not node then
				return
			end
			sel[buf] = { node }
			select_node(node)
		end

		local function node_incremental()
			local buf = vim.api.nvim_get_current_buf()
			local stack = sel[buf]
			-- (Re)initialise if the stack has drifted out of sync with the selection.
			if not stack or #stack == 0 or not node_matches_selection(stack[#stack]) then
				local node = root_node_for_range(visual_range())
				if not node then
					return
				end
				sel[buf] = { node }
				select_node(node)
				return
			end
			-- Grow to the nearest ancestor whose range differs from the selection.
			local node = stack[#stack]
			while node do
				local parent = node:parent()
				if not parent or parent == node then
					break
				end
				node = parent
				if not node_matches_selection(node) then
					table.insert(stack, node)
					select_node(node)
					return
				end
			end
		end

		local function node_decremental()
			local buf = vim.api.nvim_get_current_buf()
			local stack = sel[buf]
			if not stack or #stack < 2 then
				return
			end
			table.remove(stack)
			select_node(stack[#stack])
		end

		local function pwrap(fn)
			return function()
				pcall(fn)
			end
		end

		--------------------------------------------------------------------------
		-- Per-buffer activation
		--
		-- On `main`, highlight/fold/indent are no longer plugin "modules" — you
		-- start them yourself via the native API. Attach on every FileType and
		-- let vim.treesitter.start() decide (it errors when no parser exists, so
		-- we guard it and only wire up the rest when it succeeds).
		--------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("batman_treesitter", { clear = true }),
			callback = function(ev)
				if not pcall(vim.treesitter.start, ev.buf) then
					return
				end

				-- Tree-sitter based folding (native).
				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

				-- Tree-sitter based indentation (experimental, provided by main).
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

				-- Incremental selection keymaps (buffer-local).
				local opts = { buffer = ev.buf, silent = true }
				vim.keymap.set(
					"n",
					"<C-space>",
					pwrap(init_selection),
					vim.tbl_extend("force", opts, { desc = "TS: start selection" })
				)
				vim.keymap.set(
					"x",
					"<C-space>",
					pwrap(node_incremental),
					vim.tbl_extend("force", opts, { desc = "TS: expand selection" })
				)
				vim.keymap.set(
					"x",
					"<bs>",
					pwrap(node_decremental),
					vim.tbl_extend("force", opts, { desc = "TS: shrink selection" })
				)
			end,
		})

		-- Fold display preferences (start fully open, never auto-collapse).
		vim.opt.foldenable = false
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99

		-- nvim-ts-autotag works against the native treesitter API, independent of
		-- the nvim-treesitter branch, and still needs its own setup call.
		require("nvim-ts-autotag").setup({
			opts = {
				enable_close = true,
				enable_rename = true,
				enable_close_on_slash = true,
			},
		})
	end,
}
