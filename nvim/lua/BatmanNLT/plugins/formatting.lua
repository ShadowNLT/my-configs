return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		-- Formatter routing for JS/TS/JSON/CSS: use the project's prettier when the
		-- project is actually set up for prettier, otherwise fall back to biome (our
		-- default). Biome can't format scss/less/yaml/markdown/html/graphql/liquid,
		-- so those stay on prettier unconditionally below.
		local prettier_markers = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.json5",
			".prettierrc.js",
			".prettierrc.cjs",
			".prettierrc.mjs",
			".prettierrc.ts",
			".prettierrc.cts",
			".prettierrc.mts",
			".prettierrc.toml",
			"prettier.config.js",
			"prettier.config.cjs",
			"prettier.config.mjs",
			"prettier.config.ts",
			"prettier.config.cts",
			"prettier.config.mts",
		}
		local uv = vim.uv or vim.loop
		local function project_uses_prettier(bufnr)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			if fname == "" then
				return false
			end
			local dir = vim.fs.dirname(fname)
			-- 1. a prettier config file anywhere up the tree
			if vim.fs.root(dir, prettier_markers) then
				return true
			end
			-- 2. a project-local prettier binary (installed as a dependency)
			local nm_root = vim.fs.root(dir, "node_modules")
			if nm_root and uv.fs_stat(nm_root .. "/node_modules/.bin/prettier") then
				return true
			end
			-- 3. a "prettier" key (config or dependency) in package.json
			local pkg_root = vim.fs.root(dir, "package.json")
			if pkg_root then
				local f = io.open(pkg_root .. "/package.json", "r")
				if f then
					local content = f:read("*a")
					f:close()
					if content and content:match('"prettier"%s*:') then
						return true
					end
				end
			end
			return false
		end
		local function prettier_or_biome(bufnr)
			return project_uses_prettier(bufnr) and { "prettier" } or { "biome" }
		end

		conform.setup({
			formatters_by_ft = {
				-- prettier if the project is set up for it, otherwise biome
				javascript = prettier_or_biome,
				javascriptreact = prettier_or_biome,
				typescript = prettier_or_biome,
				typescriptreact = prettier_or_biome,
				json = prettier_or_biome,
				css = prettier_or_biome,
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
