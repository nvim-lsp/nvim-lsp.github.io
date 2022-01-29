local util = require('lspconfig/util')

-- FIXME: These should probably be defined in lspconfig server configurations
local languages = {
    als = 'Ada',
    angularls = 'Angular',
    ansiblels = 'Ansible',
    arduino_language_server = 'Arduino',
    asm_lsp = 'Assembly',
    awk_ls = 'awk',
    bashls = 'Bash',
    beancount = 'Beancount',
    bicep = 'Bicep',
    bsl_ls = 'OneScript',
    ccls = 'C/C++/ObjC',
    clangd = 'C/C++/ObjC',
    clojure_lsp = 'Clojure',
    cmake = 'CMake',
    codeqlls = 'CodeQL',
    crystalline = 'Crystalline',
    csharp_ls = 'C#',
    cssls = 'CSS',
    cssmodules_ls = 'CSS',
    cucumber_language_server = 'Cucumber',
    dartls = 'Dart',
    denols = 'Deno',
    dhall_lsp_server = 'Dhall',
    diagnosticls = 'Diagnostics',
    dockerls = 'Docker',
    dotls = 'Dot',
    efm = 'Diagnostics',
    elixirls = 'Elexir',
    elmls = 'Elm',
    ember = 'Ember',
    emmet_ls = 'Emmet',
    erlangls = 'Erlang',
    esbonio = 'Sphinx',
    eslint = 'JavaScript',
    flow = 'Flow',
    flux_lsp = 'Flux',
    foam_ls = 'Foam',
    fortls = 'Fortan',
    fsautocomplete = 'F#',
    fstar = 'FStar',
    gdscript = 'GDScript',
    ghcide = 'Haskell',
    golangci_lint_ls = 'Go',
    gopls = 'Go',
    grammarly = 'Grammarly',
    graphql = 'GraphQL',
    groovyls = 'Java',
    haxe_language_server = 'Haxe',
    hie = 'Haskell',
    hls = 'Haskell',
    html = 'HTML',
    idris2_lsp = 'Idris',
    intelephense = 'PHP',
    java_language_server = 'Java',
    jdtls = 'Java',
    jedi_language_server = 'Python',
    jsonls = 'JSON',
    jsonnet_ls = 'Jsonnet',
    julials = 'Julia',
    kotlin_language_server = 'Kotlin',
    lean3ls = 'Lean',
    leanls = 'Lean',
    lelwel_ls = 'Lelwel',
    lemminx = 'XML',
    ltex = 'LaTeX',
    metals = 'Scala',
    mint = 'Mint',
    nickel_ls = 'Nickel',
    nimls = 'Nimble',
    ocamlls = 'OCaml',
    ocamllsp = 'OCaml',
    omnisharp = 'C#',
    opencl_ls = 'OpenCL',
    pasls = 'OpenCL',
    perlls = 'Perl',
    perlpls = 'Perl',
    phpactor = 'PHP',
    powershell_es = 'PowerShell',
    prismals = 'Prisma',
    psalm = 'PHP',
    puppet = 'Puppet',
    purescriptls = 'PureScript',
    pylsp = 'Python',
    pyre = 'Python',
    pyright = 'Python',
    quick_lint_js = 'JavaScript',
    r_language_server = 'R',
    racket_langserver = 'Racket',
    remark_ls = 'Markdown',
    rescriptls = 'ReScript',
    rls = 'Rust',
    rnix = 'Nix',
    robotframework_ls = 'Robot',
    rome = 'JavaScript',
    rust_analyzer = 'Rust',
    scry = 'Crystal',
    serve_d = 'D',
    sixtyfps = 'SixtyFPS',
    solang = 'Solidity',
    solargraph = 'Ruby',
    solc = 'Solidity',
    solidity_ls = 'Solidity',
    sorbet = 'Ruby',
    sourcekit = 'Swift/C/C++/ObjC',
    spectral = 'YAML',
    sqlls = 'SQL',
    sqls = 'SQL',
    stylelint_lsp = 'CSS',
    sumneko_lua = 'Lua',
    svelte = 'Svelte',
    svls = 'Verilog',
    tailwindcss = 'CSS',
    taplo = 'TOML',
    terraform_lsp = 'Terraform',
    terraformls = 'Terraform',
    texlab = 'LaTeX',
    tflint = 'Terraform',
    theme_check = 'Liquid',
    tsserver = 'TypeScript',
    typeprof = 'Ruby',
    vala_ls = 'Vala',
    vdmj = 'VDMJ',
    verible = 'Verilog',
    vimls = 'Vim',
    vls = 'V',
    volar = 'Vue',
    vuels = 'Vue',
    yamlls = 'YAML',
    zeta_note = 'Markdown',
    zk = 'Markdown',
    zls = 'Zig'
}

-- https://github.github.com/gfm/#backslash-escapes
local function excape_markdown_punctuations(str)
    local pattern =
    '\\(\\*\\|\\.\\|?\\|!\\|"\\|#\\|\\$\\|%\\|\'\\|(\\|)\\|,\\|-\\|\\/\\|:\\|;\\|<\\|=\\|>\\|@\\|\\[\\|\\\\\\|\\]\\|\\^\\|_\\|`\\|{\\|\\\\|\\|}\\)'
    return vim.fn.substitute(str, pattern, '\\\\\\0', 'g')
end

local function read_remote_json(module, package_json)
	local function create_tmpdir(closure)
		local tempdir = os.getenv('DOCGEN_TEMPDIR') or vim.loop.fs_mkdtemp('/tmp/nvim-lsp.XXXXXX')
		local result = closure(tempdir)

		if not os.getenv('DOCGEN_TEMPDIR') then
			os.execute('rm -rf ' .. tempdir)
		end

		return result
	end

	return create_tmpdir(function(tempdir)
		local package_json_name = util.path.join(tempdir, module .. '.package.json')
		local args = os.getenv('DOCGEN_DEBUG') and { '-vs' } or {}

		if not util.path.is_file(package_json_name) then
			os.execute(string.format('curl %s -L -o %q %q', table.concat(args, ' '), package_json_name, package_json))
		end

		if util.path.is_file(package_json_name) then
			local h = io.open(package_json_name)
			local s = h:read('*a')
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
	local docs = config.docs or {}
	local lang = languages[name] or name
	local data = load_external_data(name, docs)

	local settings = {}
	if data then
		local default_settings = (data.contributes or {}).configuration or {}
		if default_settings.properties then
			for k, v in pairs(default_settings.properties) do
				settings[k] = {
                    type = v.type,
                    items = v.items,
                    default = vim.inspect(v.default),
                    description = v.description and excape_markdown_punctuations(v.description) or nil,
                }
			end
		end
	end

	local commands = {}
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

    local default_config = {}
    local keys = vim.tbl_keys(config.default_config)
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = config.default_config[k]
        if type(v) == 'function' then
            local info = debug.getinfo(v)
            local file = io.open(string.sub(info.source, 2), 'r')

            local fileContent = {}
            for line in file:lines() do
                table.insert(fileContent, line)
            end
            io.close(file)

            local root_dir = {}
            for i = info.linedefined, info.lastlinedefined do
                table.insert(root_dir, fileContent[i])
            end

            v = table.concat(root_dir, '\n'):gsub('.*function', 'function')
        else
            v = vim.inspect(v):gsub('<function %d>', 'function() --[[ see lua configuration file ]] end')
        end

        table.insert(default_config, string.format('%s = %s,', k, v))
    end

	return {
		name = name,
		language = lang,
		docs = docs,
		settings = settings,
		commands = commands,
		default_config = table.concat(default_config, '\n'),
	}
end

local function main()
	local parent = 'lspconfig/server_configurations/'
	local root = 'src/nvim-lspconfig/lua/' .. parent
	local list = {}

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
