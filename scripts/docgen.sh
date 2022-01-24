#!/usr/bin/env bash
set -e

nvim --clean -u NONE -E -R --headless +'set rtp+=$PWD/src/nvim-lspconfig' +'luafile scripts/docgen.lua' +q

python src/generate.py

mkdocs build
