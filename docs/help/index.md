---
title: What is nvim-lspconfig?
---
# What is nvim-lspconfig? Does nvim-lspconfig provide a language server client?

nvim-lspconfig includes *none* of the language server client implementation. All of the code for the language server client is located in the core of neovim. Lspconfig is a helper plugin that leverages the language client API in neovim core for an easier to use experience. Lspconfig handles:

* launching a language server when a matching filetype is detected
* Sending the correct initialization options and settings (these are two separate things in the LSP specification) during launch
* attaching new buffers you open to the currently active language server

Compare directly using the core API:

```lua
LaunchPyright = function()
  local client_id = vim.lsp.start_client({cmd = {"pyright-langserver", "--stdio"}});
  vim.lsp.buf_attach_client(0, client_id)
end

vim.cmd([[
  command! -range LaunchPyright  execute 'lua LaunchPyright()'
]])
```

To using lspconfig:

```lua
require('lspconfig').pyright.setup()
```

## Do I need lspconfig to use neovim's LSP?

You can use the built-in language server client *without* nvim-lspconfig, you'll just have to write out the server configuration and start/attach clients to buffers manually (see above or `:help lsp`).

## Why do I have to install nvim-jdtls/nvim-metals if I have nvim-lspconfig installed already? (or vice versa)

nvim-lspconfig (and neovim core) do not provide any support for custom extensions to the LSP specification. Many servers go "off-spec" and add their own functionality, which requires custom handlers. Language server specific plugins like nvim-jdtls and nvim-metals can be safely installed alongside nvim-lspconfig, and you should prefer language specific extensions for their respective servers. Additional guides/documentation for developing language specific plugins will be provided in the neovim 0.7-0.8 release timeframe.
