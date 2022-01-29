---
hide:
  - toc
---
# Configurations

Installing language servers manually is very easy. The installation instructions for each server can be found in the navigation.

For the vast majority of servers, this is a one-time, one-line installation (`npm i -g pyright`, `dnf install clang-tools-extra`, `brew install lua-language-server`, etc.). It is preferred to use your system package manager as this will handle automatic updates for you. Installing servers manually and ensuring they are on your path minimizes the point of failure, and makes it easier to debug server breakage.
