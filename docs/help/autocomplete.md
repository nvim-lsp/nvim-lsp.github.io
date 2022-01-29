# Autocompletion (not built-in) vs. completion (built-in)
Neovim does not support built-in autocompletion. As mentioned in the readme, you can bind the completion results to omnifunc for on-demand completion. To use autocompletion, please use an external plugin. We recommend [nvim-cmp](https://github.com/hrsh7th/nvim-cmp/), the successor/rewrite of [nvim-compe](https://github.com/hrsh7th/nvim-compe).

Please note, in order to provide completion, text must be synchronized on each completion request. If you notice slowdowns, the most likely candidate is a slow language server bottlenecking your autocompletion plugin.

## nvim-cmp

For installing nvim-cmp, with autocompletion support for snippets/LSP, you can follow the below snippet. Note, this does not include your server configuration. If you are using `nvim-cmp` **do not use neovim's built-in omnifunc** as it cannot support the additional completion items returned from servers due to the capabilities enabled by nvim-cmp.

```lua
local use = require('packer').use
require('packer').startup(function()
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
  use 'L3MON4D3/LuaSnip' -- Snippets plugin
end)

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
```

### Auto-import

The above snippet maps the necessary confirm on enter mapping to use auto-import. An example to show how this works:

1. Make sure tsserver is installed according to the lspconfig wiki, and if you want, use our [autocompletion example init.lua](https://github.com/mjlbach/defaults.nvim/blob/master/init.lua).
2. `mkdir test && cd test && npm init`
3. Follow the prompts to create a project
3. `npm install lodash --save`
4. `npm install @types/lodash --save-dev`
5. `echo import { } from "lodash" >> index.js`
6. `nvim index.js`
7. Check the language server is running with `:LspInfo`
8. type `debounce` on line 2 and hit `enter` (`<CR>`)

Note: This currently does not work with typescript server (theia) on Windows due to an upstream bug in theia, see https://github.com/theia-ide/typescript-language-server/issues/135

## coq_nvim

Note: coq_nvim requires Python 3.8.2 or above with `venv` package, and SQLite.

coq_nvim requires wrapping the config table passed to `setup {}`. See the example below:

```lua
local use = require('packer').use
require('packer').startup(function()
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use { 'ms-jpq/coq_nvim', run = 'python3 -m coq deps' }
  use 'ms-jpq/coq.artifacts'
  use 'ms-jpq/coq.thirdparty'
end)

local lspconfig = require('lspconfig')

-- Automatically start coq
vim.g.coq_settings = { auto_start = 'shut-up' }

-- Enable some language servers with the additional completion capabilities offered by coq_nvim
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup(require('coq').lsp_ensure_capabilities({
    -- on_attach = my_custom_on_attach,
  }))
end
```

## ddc.vim

Note: `ddc.vim` requires deno to be available on PATH.
 
```lua
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local use = require('packer').use
require('packer').startup(function()
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'vim-denops/denops.vim'
  use 'Shougo/ddc.vim'
  use 'Shougo/ddc-nvim-lsp'
  use 'Shougo/ddc-matcher_head'
  use 'Shougo/ddc-sorter_rank'
end)

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'rust_analyzer', 'pyright', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup{
    -- on_attach = my_custom_on_attach,
  }
end

vim.cmd [[ 
  call ddc#custom#patch_global('sourceOptions', {
        \ '_': {
        \   'matchers': ['matcher_head'],
        \   'sorters': ['sorter_rank']},
        \ })

  call ddc#custom#patch_global('sources', ['nvim-lsp'])
  call ddc#custom#patch_global('sourceOptions', {
        \ 'nvim-lsp': {
        \   'mark': 'lsp',
        \   'forceCompletionPattern': '\.\w*|:\w*|->\w*' },
        \ })
  
  call ddc#enable()
]]
```
