---
title: Comparison to other LSP ecosystems
---
# Comparison to other LSP ecosystems (CoC, vim lsp, etc.)

## What is included in the built-in client?

The built-in language server client implements the language server protocol as the [specification](https://microsoft.github.io/language-server-protocol/specifications/specification-3-17/#textDocument_signatureHelp) intends. The client is extensible, so plugins are free (and encouraged) to implement support for servers which add additional functionality outside the specification.

Client-side functionality such as auto-completion and auto-pairs are not part of the LSP specification, and are not built into neovim. Snippets are provided by certain language servers, and the built-in omnifunc has primitive snippet support. These are generic client capabilities that are broader than the language server protocol, but often can use language servers as an additional source. The following plugins provide good integration with the built-in client:

* [nvim-cmp](https://github.com/hrsh7th/nvim-cmp): auto-completion
* [LuaSnip](https://github.com/L3MON4D3/LuaSnip): snippets support
* [nvim-autopairs](https://github.com/windwp/nvim-autopairs): auto-pairs


## Should I use CoC.nvim, vim-lsc, vim-lsp, or neovim's built-in language server client?

All clients are terrific and have amazing communities of contributors. 

**Reasons you may choose the neovim's built-in language server client:**

* It's very extensible
  * all UI elements and behavior can be styled to your liking by overriding a handler in your init.vim/init.lua
* It's built into neovim
* Lua is a nice language to work in
* LuaJIT is an extremely fast tracing interpreter
* The client leverages libuv's event loop for fast asynchronous communication and an extremely fast json parser
* You can mix and match snippets, auto-pairs, and auto-completion plugins
* There are no dependencies for running the built-in client
  * many servers are written in javasript and will require node.js
  
**Reasons you might prefer CoC.nvim:**

* CoC provides functionality that is unrelated to (and beyond) language server support (autocompletion, coc-explorer, coc-pairs, coc-lists)
  * the built-in client does not implement autocompletion, you will need a plugin for this
  * autocompletion is not a part of the LSP specification, only completion is
* CoC.nvim manages it's own plugins (snippets, fuzzy searchers, lists)
  * the built-in client does not need to be installed
  * users will typically install lspconfig + an autocomplete extension + a snippets extension via their choice of package manager
* CoC.nvim has a dedicated plugin (and maintainer) per language
  * nvim-lspconfig supports a large number of language servers, but doesn't implement off-spec functionality like CoC does for each one
  * there are an increasing number of plugins built around the built-in LSC (nvim-jdtls, nvim-metals, flutter-tools.nvim)
* CoC.nvim uses a fork of vscode's tsserver extension for typescript/javascript
  * tsserver does not implement the LSP specification yet (there are plans to do so)
  * the vscode extension uses it's own custom interface to tsserver
  * nvim-lspconfig provides support for the [theia-IDE wrapper around tsserver](https://github.com/theia-ide/typescript-language-server)
  * For now, CoC.nvim will provide a closer experience to vscode's typescript extension than nvim-lspconfig + theia + null-ls
* CoC.nvim is an older, more established plugin
