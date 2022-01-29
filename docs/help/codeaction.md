# Code Actions

Code actions are not present on each server. There is no way to query the total available code actions for a document, as they must be requested at a certain point. To show a sign when a code action is available, you can  modify the following and add to your config directory:

```lua
--lua/code_action_utils.lua
local M = {}

local lsp_util = vim.lsp.util

function M.code_action_listener()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = lsp_util.make_range_params()
  params.context = context
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, _, result)
    -- do something with result - e.g. check if empty and show some indication such as a sign
  end)
end

return M
```

And the following in your configuration to call the function:

```vim
 autocmd CursorHold,CursorHoldI * lua require('code_action_utils').code_action_listener()
```

