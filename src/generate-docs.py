from mdutils.mdutils import MdUtils
import yaml
import json
import os


def generate_yaml(file, entries):
    tpl = yaml.safe_load(file)
    langs = []

    for e in entries:
        name, lang = e["name"], e["language"]
        langs.append({"%s (%s)" % (name, lang): "configurations/%s.md" % name})

    tpl["nav"] = [
        {"Home": "index.md"},
        {"Install": "install.md"},
        {
            "Configurations": [
                {"Introduction": "configurations/index.md"},
                {"Languages": langs}
            ]
        },
        {
            "Help": [
                {"What is nvim-lspconfig?": "help/index.md"},
                {"Autocompletion": "help/autocomplete.md"},
                {"Code Actions": "help/codeaction.md"},
                {"Comparison to other LSP ecosystems": "help/compare.md"},
                {"Complete init.lua example": "help/init.md"},
                {"Connecting to remote language servers": "help/remote.md"},
                {"Language spesific plugins": "help/plugins.md"},
                {"Project local setting": "help/local.md"},
                {"Running language servers in containers": "help/containers.md"},
                {"Snippets": "help/snippets.md"},
                {"UI Customization": "help/customization.md"},
                {"Understanding setup {}": "help/setup.md"},
                {"User contributed tips": "help/tips.md"},

            ]
        },
    ]

    return tpl


def generate_header_md(entry, doc):
    doc.new_header(level=1, title="%s (%s)" % (entry["name"], entry["language"]))
    doc.new_paragraph(entry["docs"]["description"])


def generate_setup_md(entry, doc):
    doc.new_header(level=2, title="Setup")
    doc.insert_code("require'lspconfig'.%s.setup{}" % entry["name"], language="lua")

    cmds = []
    if type(entry["commands"]) is dict:
        items = sorted(list(entry["commands"].items()))
        for k, v in items:
            cmds.append("%s: %s" % (k, v["description"]))

    if len(cmds) > 0:
        doc.new_header(level=3, title="Commands")
        doc.new_list(cmds)

    if len(entry["default_config"]) > 0:
        doc.new_header(level=3, title="Default values")
        doc.insert_code(entry["default_config"], language="lua")


def generate_settings_md(entry, doc):
    if type(entry["settings"]) is dict:
        items = sorted(list(entry["settings"].items()))
        if len(items) > 0:
            doc.new_header(level=2, title="Available settings")

            for k, v in items:
                settings = []

                doc.new_header(level=3, title="`%s`" % k)

                if "type" in v:
                    if v["type"] == "enum":
                        doc.insert_code("enum %s" % v["enum"])
                    else:
                        settings.append("Type: `%s`" % v["type"])

                if "default" in v:
                    settings.append("Default: `%s`" % v["default"])

                if "items" in v:
                    settings.append("Array items: `%s`" % v["items"])

                if len(settings) > 0:
                    doc.new_list(settings)

                if "description" in v:
                    doc.new_paragraph(v["description"])


def generate_md(entry):
    filename = os.path.join("docs/configurations/", entry["name"] + ".md")
    doc = MdUtils(file_name=filename)

    generate_header_md(entry, doc)
    generate_setup_md(entry, doc)
    generate_settings_md(entry, doc)

    doc.create_md_file()


def main():
    with open('data.json', 'r') as f:
        data = json.load(f)

        with open('src/mkdocs.yml', 'r') as d:
            conf = generate_yaml(d, data)
            with open('mkdocs.yml', 'w') as t:
                yaml.dump(conf, t)

        for entry in data:
            generate_md(entry)


if __name__ == "__main__":
    main()
