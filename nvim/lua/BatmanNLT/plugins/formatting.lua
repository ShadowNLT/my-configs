return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Formatter routing for JS/TS/JSON/CSS. The repo's own tool wins by explicit
		-- opt-in marker, checked most-specific first:
		--   1. oxfmt  — if .oxfmtrc.json / .oxfmtrc is found up the tree. Some repos
		--      (e.g. vivenu-core) format with oxfmt, NOT prettier, and have no
		--      .prettierrc at all. Falling back to prettier there rewrote the whole
		--      file to prettier's defaults (semicolons + bracket spaces), fighting
		--      oxfmt's semi:false / bracketSpacing:false style on every save.
		--   2. biome  — if biome.json / biome.jsonc is found up the tree.
		--   3. prettier — the default. It honors a repo's .prettierrc when present
		--      and falls back to its own defaults when not, so an unconfigured (or
		--      ambiguous) buffer still gets a sane, standard style.
		-- Ordering matters: the unknown case stays SAFE (prettier), and a repo that
		-- opts into oxfmt/biome never gets prettier's conflicting style imposed.
		-- oxfmt/biome can't format scss/less/yaml/markdown/html/graphql/liquid, so
		-- those stay on prettier unconditionally below.
		local oxfmt_markers = { ".oxfmtrc.json", ".oxfmtrc" }
		local biome_markers = { "biome.json", "biome.jsonc" }
		local function js_formatter(bufnr)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local dir = fname ~= "" and vim.fs.dirname(fname) or vim.fn.getcwd()
			if vim.fs.root(dir, oxfmt_markers) then
				return { "oxfmt" }
			elseif vim.fs.root(dir, biome_markers) then
				return { "biome" }
			end
			return { "prettier" }
		end

		conform.setup({
			formatters_by_ft = {
				-- prettier by default; oxfmt/biome only when the repo opts in (see above)
				javascript = js_formatter,
				javascriptreact = js_formatter,
				typescript = js_formatter,
				typescriptreact = js_formatter,
				json = js_formatter,
				css = js_formatter,
				-- prettier-only (biome does not format these)
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
				go = { "goimports_reviser", "goimports", "golines", "gofumpt" },
			},
			formatters = {
				-- oxfmt uses conform's builtin definition (command from node_modules,
				-- stdin via --stdin-filepath, cwd resolved to the nearest .oxfmtrc). No
				-- override needed here; js_formatter above just routes to it by name.
				golines = {
					prepend_args = {
						"--base-formatter=gofumpt",
					},
				},
				goimports_reviser = {
					command = "goimports-reviser",
					stdin = false,
					args = function(ctx)
						-- Resolve a stable dirname for go.mod lookup
						local bufnr = (type(ctx.buf) == "number" and ctx.buf) or vim.api.nvim_get_current_buf()
						local fname = ctx.filename
						if not fname or fname == "" then
							local ok_name, got = pcall(vim.api.nvim_buf_get_name, bufnr)
							if ok_name and got and got ~= "" then
								fname = got
							end
						end
						local dirname = (fname and fname ~= "" and vim.fs.dirname(fname))
							or ctx.dirname
							or (vim.uv or vim.loop).cwd()

						-- Find nearest go.mod upwards
						local gomod = vim.fs.find("go.mod", { upward = true, path = dirname })[1]
						local mod
						if gomod then
							local f = io.open(gomod, "r")
							if f then
								local s = f:read("*a")
								f:close()
								mod = s:match("^module%s+([%w%p%-_/%.]+)") or s:match("\nmodule%s+([%w%p%-_/%.]+)")
							end
						end

						local args = {
							"-rm-unused",
							"-set-alias",
							"-format",
							"-imports-order",
							"std,general,company,project,blanked,dotted",
						}
						if mod then
							table.insert(args, "-project-name")
							table.insert(args, mod)
						end
						table.insert(args, "$FILENAME")
						return args
					end,

					-- ✅ Guard against temp/empty/unnamed buffers and files without a package decl
					condition = function(ctx)
						local uv = vim.uv or vim.loop
						-- Resolve filename reliably
						local bufnr = (type(ctx.buf) == "number" and ctx.buf) or vim.api.nvim_get_current_buf()
						local fname = ctx.filename
						if not fname or fname == "" then
							local ok_name, got = pcall(vim.api.nvim_buf_get_name, bufnr)
							if ok_name and got and got ~= "" then
								fname = got
							end
						end
						if not fname or fname == "" then
							return false
						end

						-- File must exist and be non-empty
						local ok_stat, st = pcall(uv.fs_stat, fname)
						if not ok_stat or not st or st.type ~= "file" or (st.size or 0) == 0 then
							return false
						end

						-- Buffer must look like a Go file with a package decl within first ~50 lines
						local ok_count, line_count = pcall(vim.api.nvim_buf_line_count, bufnr)
						if not ok_count then
							return false
						end
						local to = math.min(50, line_count)
						local ok_lines, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, to, false)
						if not ok_lines then
							return false
						end
						for _, l in ipairs(lines) do
							if l:match("^%s*package%s+[%w_]+") then
								return true
							end
						end
						return false
					end,
				},
			},
			format_on_save = {
				-- Use ONLY the configured formatters (prettier for JS/TS, etc.).
				-- prettier already does the right thing: honor a repo's config when
				-- present, fall back to its own defaults when not. "never" stops
				-- conform from handing off to the LSP (vtsls), whose default style
				-- ignores .prettierrc and was the source of the mystery formatting.
				lsp_format = "never",
				async = false,
				timeout_ms = 5000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_format = "never",
				async = false,
				timeout_ms = 5000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
