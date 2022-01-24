#!/usr/bin/env bash
set -e

nvim --clean -u NONE -E -R --headless +'set rtp+=$PWD/src/nvim-lspconfig' +'luafile src/generate-data.lua' +q

python src/generate-docs.py

mkdocs build
