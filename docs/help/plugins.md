# Language specific plugins

Nvim-lspconfig is meant to implement basic configuration and settings for most language servers. The beauty of the language server protocol, is most language servers should expose their entire functionality without any special per-server treatment.

Some servers send requests outside of the language server protocol specification to extend the functionality of the protocol. Eclipse JDTLS is one such example. An ecosystem of per language plugins is forming around neovim's core implementation to provide an enhanced experience compared to nvim-lspconfig. We recommend you install these plugins if you are using the language in question. Here are some recommendations:

* [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls) (Java's [Eclipse JDT](https://github.com/eclipse/eclipse.jdt.ls))
* [nvim-metals](https://github.com/scalameta/nvim-metals) (Scala's [Metals](https://scalameta.org/metals/))
* [flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim) ([Flutter](https://flutter.dev/))
* [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim/) (Rust's [rust-analyzer](https://rust-analyzer.github.io/))
* [lean.nvim](https://github.com/Julian/lean.nvim) ([Lean](https://leanprover.github.io/))
* [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) (jsonls): Note, this provides schemas for jsonls but still depends on lspconfig.
* [grammar-guard.nvim](https://github.com/brymer-meneses/grammar-guard.nvim) (ltex-ls)
* [omnisharp-extended-lsp.nvim](https://github.com/Hoffs/omnisharp-extended-lsp.nvim) Add support for decompiling.
