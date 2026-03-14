return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      -- Keymaps via LspAttach autocmd (replaces on_attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>af", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>an", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>ap", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      -- Enable LSP servers (configs provided by nvim-lspconfig)
      vim.lsp.enable({ "ts_ls", "gopls", "terraformls" })

      -- Diagnostic display
      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = true,
        signs = true,
      })
    end,
  },
}
