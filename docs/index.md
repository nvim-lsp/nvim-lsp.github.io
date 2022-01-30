---
hide:
  - navigation
  - toc
---
# lspconfig

A collection of common configurations for Neovim's built-in [language server client](https://neovim.io/doc/user/lsp.html).

This plugin allows for declaratively configuring, launching, and initializing language servers you have installed on your system. 
**Disclaimer: Language server configurations are provided on a best-effort basis and are community-maintained.**

`lspconfig` has extensive help documentation, see `:help lspconfig`.

## LSP overview

Neovim supports the Language Server Protocol (LSP), which means it acts as a client to language servers and includes a Lua framework `vim.lsp` for building enhanced LSP tools. LSP facilitates features like:

- go-to-definition
- find-references
- hover
- completion
- rename
- format
- refactor

Neovim provides an interface for all of these features, and the language server client is designed to be highly extensible to allow plugins to integrate language server features which are not yet present
in Neovim core such as [**auto**-completion](help/autocomplete.md) (as opposed to manual completion with omnifunc) and [snippet integration](help/snippets.md).

