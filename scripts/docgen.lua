require 'lspconfig'
local util = require 'lspconfig/util'

local function read_remote_json(module, package_json)
    local function create_tmpdir(closure)
        local tempdir = os.getenv 'DOCGEN_TEMPDIR' or vim.loop.fs_mkdtemp '/tmp/nvim-lsp.XXXXXX'
        local result = closure(tempdir)

        if not os.getenv 'DOCGEN_TEMPDIR' then
            os.execute('rm -rf ' .. tempdir)
        end

        return result
    end

    return create_tmpdir(function(tempdir)
        local package_json_name = util.path.join(tempdir, module .. '.package.json')
        local args = os.getenv 'DOCGEN_DEBUG' and { '-vs' } or {}

        if not util.path.is_file(package_json_name) then
            os.execute(string.format('curl %s -L -o %q %q', table.concat(args, ' '), package_json_name, package_json))
        end

        if util.path.is_file(package_json_name) then
            local h = io.open(package_json_name)
            local s = h:read '*a'
            io.close(h)
            return vim.fn.json_decode(s)
        end

        return nil
    end)
end

local function load_external_data(name, docs)
    local data = nil

    if docs.package_json then
        data = read_remote_json(name, docs.package_json)
        if not data then
            print(string.format('Failed to download package.json for %q at %q', name, docs.package_json))
            os.exit(1)
            return
        end
    end

    return data
end

local function load_config(name, config)
    local commands = {}
    local docs = config.docs or {}
    local label = docs.language_name and string.format('%s (%s)', docs.language_name, name) or name
    local data = load_external_data(name, docs)

    -- Dowload and parse external settings
    local settings = {}
    if data then
        local default_settings = (data.contributes or {}).configuration or {}
        if default_settings.properties then
            for k, v in pairs(default_settings.properties) do
                if type(v.default) == 'table' then
                    v.default = vim.inspect(v.default)
                end
                settings[k] = v
            end
        end
    end

    -- Filter out invalid values in configuration settings
    if type(config.commands) == 'table' then
        for k, v in pairs(config.commands) do
            local filtered = {}
            for kk, vv in pairs(v) do
                if type(vv) ~= 'function' then
                    filtered[kk] = vv
                end
            end

            commands[k] = filtered
        end
    end

    -- JSON object for each configuration entry
    return {
        name = name,
        label = label,
        docs = docs,
        settings = settings,
        commands = commands,
        default_config = vim.inspect(config.default_config),
    }
end

local function main()
    local parent = 'lspconfig/server_configurations/'
    local root = 'src/nvim-lspconfig/lua/' .. parent
    local list = {}

    -- Gather configurations from lspconfig
    for _, v in ipairs(vim.fn.glob(root .. '*.lua', 1, 1)) do
        local m = v:sub(#root + 1):gsub('%.lua$', '')
        local ok, result = pcall(require, parent .. m)
        if ok then
            table.insert(list, load_config(m, result))
        end
    end

    local writer = io.open('data.json', 'w')
    writer:write(vim.json.encode(list))
    writer:close()
end

main()
