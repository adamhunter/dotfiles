return {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      local lspconfig = require("lspconfig")

      -- Shared on_attach for keymaps
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>af", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>an", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>ap", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      -- TypeScript / JavaScript
      lspconfig.ts_ls.setup({ on_attach = on_attach })

      -- Go
      lspconfig.gopls.setup({ on_attach = on_attach })

      -- Terraform
      lspconfig.terraformls.setup({ on_attach = on_attach })

      -- Diagnostic display
      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = true,
        signs = true,
      })
    end,
  },
}
