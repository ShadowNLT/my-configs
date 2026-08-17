return {
  "kylechui/nvim-surround",
  version = "^3.0.0", -- Use for stability; Omit to use `main` branch for the latest features
  event = "VeryLazy", 
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        -- Leave `s`/`S` to flash.nvim (jump / treesitter); surround uses `gs`/`gS` in visual mode.
        visual = "gs",       -- wrap selection
        visual_line = "gS",  -- wrap selection on new lines
      },
    })
  end
}
