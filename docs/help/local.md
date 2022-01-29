# Project local settings

Before doing this, please familiarize yourself with the risk of automatically running project local code in the lua interpreter.

Local settings can be configured by enabling the exrc option with `set exrc` in your init.vim
and creating a `.nvimrc` file in the project's root directory. If neovim is launched
in the same directory as `.nvimrc`, it will evaluate your user configuration first,
followed by the local configuration. An example `.nvimrc` might be as follows

```vim
lua << EOF
  local nvim_lsp = require('lspconfig')

  nvim_lsp.rust_analyzer.setup {
    root_dir = function()
      return vim.fn.getcwd()
    end
  }
EOF
```

Be aware, after enabling exrc, neovim will execute any `.nvimrc` or `.exrc` owned by 
your user, including git clones.

If the only thing you care about configuring is the language server's settings, you might be able to use the `on_init` hook and the `workspace/didChangeConfiguration` notification:

```lua
local nvim_lsp = require('lspconfig')

nvim_lsp.rust_analyzer.setup {
  on_init = function(client)
    client.config.settings.xxx = "yyyy"
    client.notify("workspace/didChangeConfiguration")
    return true
  end
}
```
