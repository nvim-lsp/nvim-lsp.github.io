#!/usr/bin/env bash

declare -A filemap=(
  ["Autocompletion.md"]="autocomplete.md"
  ["Code-Actions.md"]="codeaction.md"
  ["Comparison-to-other-LSP-ecosystems-(CoC,-vim-lsp,-etc.).md"]="compare.md"
  ["Complete-init.lua-example.md"]="init.md"
  ["Connecting-to-remote-language-servers.md"]="remote.md"
  ["Language-specific-plugins.md"]="plugins.md"
  ["Project-local-settings.md"]="local.md"
  ["Running-language-servers-in-containers.md"]="containers.md"
  ["Snippets.md"]="snippets.md"
  ["UI-Customization.md"]="customization.md"
  ["Understanding-setup-{}.md"]="setup.md"
  ["User-contributed-tips.md"]="tips.md"
)

root_path="src/nvim-lspconfig.wiki"
target_path="docs/help"

for i in "${!filemap[@]}"
do
  source="${root_path}/${i}"
  target="${target_path}/${filemap[$i]}"
  cp "$source" $target
done
