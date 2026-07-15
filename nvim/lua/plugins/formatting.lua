return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          css = { "prettier" },
          html = { "prettier" },
          markdown = { "prettier" },
          yaml = { "prettier" },
          terraform = { "terraform_fmt" },
          go = { "gofmt" },
        },
        format_on_save = {
          timeout_ms = 3000,
          lsp_fallback = true,
        },
      })
    end,
  },
}
