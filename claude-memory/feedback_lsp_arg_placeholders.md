---
name: lsp-arg-placeholders
description: "Keep function-argument placeholders enabled for every LSP server, now and for any added later"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 277fd1be-9fd5-496e-81ad-447e659aaee9
---

The user wants function-call argument placeholders (the `${1:arg}` snippet fields you Tab through after accepting a function from the cmp menu) working for **all** language servers in [[project-dotfiles]] — current ones and any LSP added in the future. They asked me to remember this proactively.

**Why:** craftzdog-style ergonomics — accept a function completion, then tab through its arguments.

**How to apply (in `nvim/lua/BatmanNLT/plugins/lsp/lspconfig.lua`):**
- Global enabler is set: `vim.lsp.config("*", { capabilities = cmp_nvim_lsp.default_capabilities() })` advertises snippet support to **every** server (including ones auto-enabled by mason-lspconfig), so most servers (ts_ls, pyright, html, cssls, …) emit arg placeholders automatically.
- Two servers need an extra explicit opt-in beyond snippet support:
  - `gopls` → `settings.gopls.usePlaceholders = true`
  - `lua_ls` → `settings.Lua.completion.callSnippet = "Replace"`
- When adding a NEW server: the global `*` capability already covers it; only add a per-server switch if that server has its own (rare, like the two above).

Also depends on a snippet engine + jump keys, already in `nvim-cmp.lua`: LuaSnip expand + `<Tab>`/`<S-Tab>` bound to `luasnip.jump`.
