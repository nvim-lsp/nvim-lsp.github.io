# User contributed tips

We list here some snippets to customize the LSP experience. These are too complex/arbitrary to be enabled by default.

## Range Formatting With a Motion

If your language server supports formatting a range of text (as opposed to a whole file), you can use this snippet to map a key to formatting a range with a motion.  For example, with this code, `gmip` in normal mode will format a paragraph.

```lua
function format_range_operator()
  local old_func = vim.go.operatorfunc
  _G.op_func_formatting = function()
    local start = vim.api.nvim_buf_get_mark(0, '[')
    local finish = vim.api.nvim_buf_get_mark(0, ']')
    vim.lsp.buf.range_formatting({}, start, finish)
    vim.go.operatorfunc = old_func
    _G.op_func_formatting = nil
  end
  vim.go.operatorfunc = 'v:lua.op_func_formatting'
  vim.api.nvim_feedkeys('g@', 'n', false)
end
vim.api.nvim_set_keymap("n", "gm", "<cmd>lua format_range_operator()<CR>", {noremap = true})
```

See https://github.com/neovim/neovim/issues/14680 for context.


## Peek Definition

To open the target of a `textDocument/definition` request in a floating window (as in VS Code's "Peek Definition"), you can use the following snippet:

```lua
local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then
    return nil
  end
  vim.lsp.util.preview_location(result[1])
end

function PeekDefinition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end
```

If the server supports [`LocationLink`](https://microsoft.github.io/language-server-protocol/specification#locationLink), this will show the full target range (e.g., function body) of the definition. Other requests like `textDocument/declaration` can be "peeked" analogously.


## Clangd

### SwitchSourceHeader

nvim-lspconfig offers the ClangdSwitchSourceHeader command by default. It simply replaces the current buffer with the corresponding file. If you'd like to open the corresponding file in a new split/vsplit, you can add such commands easily:

```lua
local function switch_source_header_splitcmd(bufnr, splitcmd)
  bufnr = require'lspconfig'.util.validate_bufnr(bufnr)
  local clangd_client = require'lspconfig'.util.get_active_client_by_name(bufnr, 'clangd')
  local params = {uri = vim.uri_from_bufnr(bufnr)}
  if clangd_client then
    clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
      if err then
        error(tostring(err))
      end
      if not result then
        print("Corresponding file can’t be determined")
        return
      end
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
    end, bufnr)
  else
    print 'textDocument/switchSourceHeader is not supported by the clangd server active on the current buffer'
  end
end

require'lspconfig'.clangd.setup {

   -----snip------

    commands = {
    	ClangdSwitchSourceHeader = {
    		function() switch_source_header_splitcmd(0, "edit") end;
    		description = "Open source/header in current buffer";
    	},
    	ClangdSwitchSourceHeaderVSplit = {
    		function() switch_source_header_splitcmd(0, "vsplit") end;
    		description = "Open source/header in a new vsplit";
    	},
    	ClangdSwitchSourceHeaderSplit = {
    		function() switch_source_header_splitcmd(0, "split") end;
    		description = "Open source/header in a new split";
    	}
    }
}
```

The commands ClangdSwitchSourceHeader* are available like normal vim commands, that is:
```
nnoremap <leader>h :ClangdSwitchSourceHeaderVSplit<CR>
```

## diagnosticls
[Auto generated config link](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#diagnosticls)

### eslint
The following is an example of integrating with eslint, it uses the **.eslinrc.js** file to identify the project root, and then uses the instance of eslint available in **node_modules**:

```lua
  local util = require "lspconfig".util

  require'lspconfig'.diagnosticls.setup{
    filetypes = {"javascript", "typescript"},
    root_dir = function(fname)
      return util.root_pattern("tsconfig.json")(fname) or
      util.root_pattern(".eslintrc.js")(fname);
    end,
    init_options = {
      linters = {
        eslint = {
          command = "./node_modules/.bin/eslint",
          rootPatterns = {".eslintrc.js", ".git"},
          debounce = 100,
          args = {
            "--stdin",
            "--stdin-filename",
            "%filepath",
            "--format",
            "json"
          },
          sourceName = "eslint",
          parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "[eslint] ${message} [${ruleId}]",
            security = "severity"
          },
          securities = {
            [2] = "error",
            [1] = "warning"
          }
        },
      },
      filetypes = {
        javascript = "eslint",
        typescript = "eslint"
      }
    }
  }
```

## EFM
[Auto generated config link](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#efm)

### eslint
The following is an example of integrating with eslint, it uses the **.eslinrc.js** file to identify the project root, and then uses the instance of eslint available in **node_modules**:

```lua
  local eslint = {
    lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
    lintIgnoreExitCode = true,
    lintStdin = true
  }
  local util = require "lspconfig".util
  
  require "lspconfig".efm.setup {
    --cmd = {"efm-langserver",},
    init_options = {documentFormatting = true},
    filetypes = {"javascript", "typescript"},
    root_dir = function(fname)
      return util.root_pattern("tsconfig.json")(fname) or
      util.root_pattern(".eslintrc.js", ".git")(fname);
    end,
    settings = {
      rootMarkers = {".eslintrc.js", ".git/"},
      languages = {
        typescript = {eslint}
      }
    }
  }
```


### eslint_d
This example uses eslint_d, which is much faster. Read more [here](https://www.npmjs.com/package/eslint_d)

```lua
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

require "lspconfig".efm.setup {
  init_options = {documentFormatting = true},
  filetypes = {"javascript", "typescript"},
  root_dir = function(fname)
    return util.root_pattern("tsconfig.json")(fname) or
    util.root_pattern(".eslintrc.js", ".git")(fname);
  end,
  settings = {
    rootMarkers = {".eslintrc.js", ".git/"},
    languages = {
      javascript = {eslint},
      typescript = {eslint}
    }
  }
}
```

## Customize LSP CodeLens and Signs

It can be helpful to customize the severity levels that get displayed as a gutter sign and/or codelens virtual text. For example, maybe you want to show everything in the gutter, but only Errors as virtualtext.

```lua
-- Set which codelens text levels to show
local original_set_virtual_text = vim.lsp.diagnostic.set_virtual_text
local set_virtual_text_custom = function(diagnostics, bufnr, client_id, sign_ns, opts)
    opts = opts or {}
    -- show all messages that are Warning and above (Warning, Error)
    opts.severity_limit = "Warning"
    original_set_virtual_text(diagnostics, bufnr, client_id, sign_ns, opts)
end

vim.lsp.diagnostic.set_virtual_text = set_virtual_text_custom
```

Or maybe you want to only show Errors in the gutter,
```lua
local orig_set_signs = vim.lsp.diagnostic.set_signs
local set_signs_limited = function(diagnostics, bufnr, client_id, sign_ns, opts)
  opts = opts or {}
  opts.severity_limit = "Error"
  orig_set_signs(diagnostics, bufnr, client_id, sign_ns, opts)
end

vim.lsp.diagnostic.set_signs = set_signs_limited
```
[source](https://www.reddit.com/r/neovim/comments/mvhfw7/can_built_in_lsp_diagnostics_be_limited_to_show_a/gvd8rb9/?utm_source=reddit&utm_medium=web2x&context=3)

Another configuration that only shows the most severe item in the gutter per line,
```lua
-- Capture real implementation of function that sets signs
local orig_set_signs = vim.lsp.diagnostic.set_signs
local set_signs_limited = function(diagnostics, bufnr, client_id, sign_ns, opts)

  -- original func runs some checks, which I think is worth doing
  -- but maybe overkill
  if not diagnostics then
    diagnostics = diagnostic_cache[bufnr][client_id]
  end

  -- early escape
  if not diagnostics then
    return
  end

  -- Work out max severity diagnostic per line
  local max_severity_per_line = {}
  for _,d in pairs(diagnostics) do
    if max_severity_per_line[d.range.start.line] then
      local current_d = max_severity_per_line[d.range.start.line]
      if d.severity < current_d.severity then
        max_severity_per_line[d.range.start.line] = d
      end
    else
      max_severity_per_line[d.range.start.line] = d
    end
  end

  -- map to list
  local filtered_diagnostics = {}
  for i,v in pairs(max_severity_per_line) do
    table.insert(filtered_diagnostics, v)
  end

  -- call original function
  orig_set_signs(filtered_diagnostics, bufnr, client_id, sign_ns, opts)
end
vim.lsp.diagnostic.set_signs = set_signs_limited
```

[source](https://www.reddit.com/r/neovim/comments/mvhfw7/can_built_in_lsp_diagnostics_be_limited_to_show_a/gvd8rb9/?utm_source=reddit&utm_medium=web2x&context=3)

## jsonls

### Use JSON schemas from SchemaStore

The [SchemaStore](https://github.com/SchemaStore/schemastore) project provides a large collection of [JSON schema](https://json-schema.org/) definitions for many common JSON file types. The [SchemaStore.nvim](https://github.com/b0o/schemastore.nvim) plugin provides access to the SchemaStore catalog as a Lua library that can be used to configure jsonls.

To use the entire SchemaStore catalog with jsonls, install the [SchemaStore.nvim](https://github.com/b0o/schemastore.nvim) plugin, then update your lspconfig jsonls settings:


To use SchemaStore.nvim with [lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#jsonls) + [jsonls](https://github.com/hrsh7th/vscode-langservers-extracted):

```lua
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
    },
  },
}
```

To use a subset of the catalog, you can select schemas by name (see [the catalog](https://github.com/SchemaStore/schemastore/blob/master/src/api/json/catalog.json) for a full list):

```lua
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas {
        select = {
          '.eslintrc',
          'package.json',
        },
      },
    },
  },
}
```

To ignore certain schemas from the catalog:

```lua
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas {
        ignore = {
          '.eslintrc',
          'package.json',
        },
      },
    },
  },
}
```

To replace certain schemas from the catalog with your own:

```lua
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas {
        replace = {
          ['package.json'] = {
            description = 'package.json overriden',
            fileMatch = { 'package.json' },
            name = 'package.json',
            url = 'https://example.com/package.json',
          },
        },
      },
    },
  },
}
```

If you want to use your own schemas in addition to schemas from SchemaStore, you can merge them:

```lua
require('lspconfig').jsonls.setup {
  settings = {
    json = {
      schemas = vim.list_extend(
        {
          {
            description = 'My Custom JSON schema',
            fileMatch = { 'foobar.json', '.foobar.json' },
            name = 'foobar.json',
            url = 'https://example.com/schema/foobar.json',
          },
        },
        require('schemastore').json.schemas {
          select = {
            '.eslintrc',
            'package.json',
          },
        }
      ),
    },
  },
}
```
## ltex-ls

To add the user dictionary from the built-in Neovim spell checker to `ltex-ls`, add the following to your LSP setup:

```
-- ===========================================
--  Add user dictionary for ltex-ls
--  * en.utf-8.add must be created using `zg`
-- ===========================================
local path = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
local words = {}

for word in io.open(path, 'r'):lines() do
  table.insert(words, word)
end

nvim_lsp.ltex.setup {
  on_attach = on_attach,
  settings = {
    ltex = {
      dictionary = {
        ['en-US'] = words,
      },
    },
  },
}
```
The changes take places when you reload the config.

## Use nvim-notify to display LSP messages

The [nvim-notify](https://github.com/rcarriga/nvim-notify) plugin can be used to display messages received from the LSP server.

```lua
vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({
    'ERROR',
    'WARN',
    'INFO',
    'DEBUG',
  })[result.type]
  notify({ result.message }, lvl, {
    title = 'LSP | ' .. client.name,
    timeout = 10000,
    keep = function()
      return lvl == 'ERROR' or lvl == 'WARN'
    end,
  })
end
```
