return {
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },
  { "tpope/vim-fugitive" },
  { "tomtom/tcomment_vim" },
  {
    "fatih/vim-go",
    ft = "go",
    config = function()
      -- Let LSP handle most things, vim-go for :GoRun, :GoTest, etc.
      vim.g.go_fmt_autosave = 0 -- conform handles formatting
      vim.g.go_def_mapping_enabled = 0 -- LSP handles go-to-definition
    end,
  },
}
