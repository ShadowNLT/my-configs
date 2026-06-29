-- Prose-friendly settings for markdown.
-- Global `wrap = false` (core/options.lua) is great for code but forces
-- horizontal scrolling in markdown, especially in vertical splits. Re-enable
-- soft wrapping here, scoped to this buffer only.
vim.opt_local.wrap = true -- soft-wrap long lines into the next visual row
vim.opt_local.linebreak = true -- break at word boundaries, not mid-word
vim.opt_local.breakindent = true -- keep wrapped lines aligned with their indent
