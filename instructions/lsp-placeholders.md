# LSP argument placeholders

Keep function-call argument placeholders (the `${1:arg}` snippet fields you Tab through after accepting a function from the completion menu) on for **every** language server — current ones and any added later.

Accept a function completion, then Tab through its arguments.

## How to apply

In `nvim/lua/BatmanNLT/plugins/lsp/lspconfig.lua`:

- Global enabler: `vim.lsp.config("*", { capabilities = cmp_nvim_lsp.default_capabilities() })` advertises snippet support to every server (including ones auto-enabled by mason-lspconfig). Most servers (ts_ls, pyright, html, cssls, …) emit arg placeholders from that alone.
- Two servers need an extra explicit opt-in:
  - `gopls` → `settings.gopls.usePlaceholders = true`
  - `lua_ls` → `settings.Lua.completion.callSnippet = "Replace"`
- When adding a new server: the global `*` capability already covers it. Only add a per-server switch if that server has its own (rare, like the two above).

Also depends on a snippet engine and jump keys, already in `nvim-cmp.lua`: LuaSnip expand plus `<Tab>` / `<S-Tab>` bound to `luasnip.jump`.
