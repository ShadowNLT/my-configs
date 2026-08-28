-- Auto-resize splits when the terminal/monitor size changes.
-- Without this, splits keep their old pixel widths after moving Ghostty
-- between monitors or resizing the window.
local augroup = vim.api.nvim_create_augroup("BatmanNLTResize", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
  desc = "Auto-equalize all splits on VimResized (monitor/window change)",
})
