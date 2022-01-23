#!/bin/sh
nvim -u NONE -E -R --headless +'set rtp+=$PWD/src' +'luafile scripts/docgen.lua' +q
python src/generate.py
mkdocs build
