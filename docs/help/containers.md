# Running language servers in containers

## Preface

Say you are developing code on a local install of a newer Linux distribution to get all the features offered there, but the code you are developing is intended to be run on a more legacy system. The libraries it needs to run, etc. all won't work on your host system, nor do you want them there, so you actually run and build the code inside of a [Docker](https://docs.docker.com/) container. The process of getting each language server to work might be a bit nuanced, but this page will help you get started and help bring to light some troubles that might occur along the way.

My creating of this page came out of a conversation with [@mjlbach](https://github.com/mjlbach) on the [nvim-lspconfig Q&A thread](https://github.com/neovim/nvim-lspconfig/discussions/667), and is very much a first attempt. Feel free to add other tips for other language servers as the might not all be the same as `clangd`, or edit this page as you make improvements & find fixes.

## Language servers

### clangd

[clangd](https://clangd.llvm.org/) is a _C_ family language server, as the name implies. In order to get this working inside of a container, while _Neovim_ runs on the host system, the setup might look something like the following:

_cclangd_: A shell script wrapper to run `clangd` inside of the passed container, or normally if no matching container is found
```sh
##! /bin/sh

## The name of the container to run `clangd` in must be passed as the first and only argument
##
## This is based off the name of the buffer and the repository, etc. it is in, so even if we
## don't end up attaching to a container, it will still be passed
[ "$#" -ne 1 ] && echo "Container name required as first and only argument" >&2 && exit 1

## Verify that a contianer by this name actually exists, and is running
if [ -z "$(docker ps -q -f name=$1 -f status=running)" ]; then
    clangd --background-index
else
    # Important part here is both the '-i' and the redirection of STDERR
    docker exec -i "$1" /usr/bin/clangd --background-index 2>/dev/null
fi
```

Then make sure that the above script is marked as executable, and in a runnable location on your system. On _Linux_, this mean that it lies somewhere on your `$PATH`, and has bee altered with `chmod +x /path/to/cclangd`. Then for your own client configuration via _Neovim_:

```lua
    -- Notably _not_ including `compile_commands.json`, as we want the entire project
    local root_pattern = lspconfig.util.root_pattern('.git')

    -- Might be cleaner to try to expose this as a pattern from `lspconfig.util`, as
    -- really it is just stolen from part of the `clangd` config
    local function project_name_to_container_name()
        -- Turn the name of the current file into the name of an expected container, assuming that
        -- the container running/building this file is named the same as the basename of the project
        -- that the file is in
        --
        -- The name of the current buffer
        local bufname = vim.api.nvim_buf_get_name(0)

        -- Turned into a filename
        local filename = lspconfig.util.path.is_absolute(bufname) and bufname or lspconfig.util.path.join(vim.loop.cwd(), bufname)

        -- Then the directory of the project
        local project_dirname = root_pattern(filename) or lspconfig.util.path.dirname(filename)

        -- And finally perform what is essentially a `basename` on this directory
        return vim.fn.fnamemodify(lspconfig.util.find_git_ancestor(project_dirname), ':t')
    end

    -- Note that via the `manager` from `server_per_root_dir_manager`, we'll get a separate instance
    -- of `clangd` as we switch between files, or even projects, inside of the right container
    --
    -- Finally, we've formed the "basename of a project" to pass to our `cclangd` script, which will
    -- then look for a matching container, or run `clangd` normally if no matching container is found
    --    /path/to/my/project
    -- would look for a container named `project`, and `docker exec` a `clangd` instance there, etc.
    lspconfig.clangd.setup{
        cmd = {
            'cclangd',
            project_name_to_container_name(),
        },
    }
```

in addition to anything else you've already setup, like a custom `on_attach` function, etc. although the configuration additions above are all that is required.

##### Additional clangd tips

* If you have a project that is setup in such a way that header files aren't installed to their standard locations on your system, each binary requires customized linking, etc. I'd highly recommend playing around with either [compiledb](https://pypi.org/project/compiledb/) or [Bear](https://github.com/rizsotto/Bear). Both of these will generate `compile_commands.json` files, which are already recognized by the default `clangd` configuration in this repo.
* You can edit the `cclangd` script to redirect `STDERR` to a file if you are interested in debugging things, just change `... 2>/dev/null` to whatever filepath you like; `... 2>/tmp/clangd.log`, etc.
* The builtin client and the handling in this repo. do a great job of handling root paths and whatnot, but you might have to play around with the `-w` option of [docker exec](https://docs.docker.com/engine/reference/commandline/exec/) depending on how your project is setup.

### `microsoft/vscode-languageserver-node` based servers

The `vscode-languageserver-node` based server expects a client to create it. The server expects the client  to supply a process id (the process id of the client). When the server cannot detect the process id, it assumes the client has exited and that it should exit. Since containers do not share process ids with the host this results in the server exiting immediately. See [here](https://github.com/microsoft/vscode-languageserver-node/issues/364#issuecomment-431385118)

A way to handle this is using `before_init` and overriding `initialize_params.process_id` with a NIL (null) value as described [here](https://github.com/neovim/neovim/issues/14504#issuecomment-833940045)

A less ideal way to deal with this is to have the host and container share process ids via the docker/podman run argument `--pid=host` as mentioned [here](https://github.com/neovim/neovim/issues/14504#issuecomment-833930180). *Do note this is considered an insecure practice by both Docker and Podman*. `man docker-run` or `man podman-run` and `/--pid=` for more info.
