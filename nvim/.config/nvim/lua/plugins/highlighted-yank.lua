return {
  "machakann/vim-highlightedyank",
  config = function()
    vim.cmd([[
      let g:highlightedyank_highlight_duration = 250
      let g:highlightedyank_highlight_group = 'YankHighlight'
    ]])
  end,
}
