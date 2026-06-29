-- incline.nvim — floating per-window filename label (top-right of each split).
-- Minimal: filetype icon + filename, color-coded by state.
--   focused + saved  -> cyan      (#5ef1ff)
--   modified/unsaved -> rose      (#ff7eb6)  <- swap this one hex if it reads fuzzy
--   inactive split   -> muted     (#7b8496)
return {
  "b0o/incline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local devicons = require("nvim-web-devicons")

    local PILL_BG   = "#232a3f"
    local CLR_SAVED = "#5ef1ff"
    local CLR_MOD   = "#ff7eb6"
    local CLR_IDLE  = "#7b8496"

    require("incline").setup({
      window = {
        margin = { vertical = 0, horizontal = 1 },
        padding = 0,
        placement = { horizontal = "right", vertical = "top" },
      },
      hide = { cursorline = true },
      render = function(props)
        local bufname = vim.api.nvim_buf_get_name(props.buf)
        local filename = vim.fn.fnamemodify(bufname, ":t")
        if filename == "" then filename = "[No Name]" end

        local modified = vim.bo[props.buf].modified
        local name_fg = modified and CLR_MOD or (props.focused and CLR_SAVED or CLR_IDLE)

        local icon, icon_fg = devicons.get_icon_color(filename)

        return {
          { "  " },
          icon and { icon, " ", guifg = icon_fg } or "",
          { filename, guifg = name_fg, gui = modified and "bold,italic" or "None" },
          { modified and " ● " or "  ", guifg = CLR_MOD },
          guibg = PILL_BG,
        }
      end,
    })
  end,
}
