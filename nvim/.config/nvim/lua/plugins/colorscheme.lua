return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      transparent_background = true, -- disables setting the background color.
    })
    vim.cmd.colorscheme "catppuccin"

    -- Set colors for line numbers
    vim.cmd("highlight LineNr guifg=#87CEEB guibg=NONE")
    vim.cmd("highlight CursorLineNR guifg=#00FF00 guibg=NONE")
  end,
}

