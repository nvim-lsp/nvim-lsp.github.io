from mdutils.mdutils import MdUtils
from subprocess import run
import yaml
import json
import os


def format_lua(name, code):
    try:
        prefix = "local config = "
        surrounded = "%s{%s}" % (prefix, code)
        proc = run(
            ["stylua", "-"],
            input=surrounded.encode(),
            check=True,
            capture_output=True
        )
        return proc.stdout.decode().replace(prefix, "")
    except:
        print("Failed to stylua: %s" % name)

    return code


def generate_yaml(file, entries):
    tpl = yaml.safe_load(file)
    langs = []

    for e in entries:
        name, lang = e["name"], e["language"]
        langs.append({"%s (%s)" % (name, lang): "configurations/%s.md" % name})

    """ FIXME: Use query to do this properly """
    tpl["nav"][2]["Configurations"][1]["Configurations"] = langs

    return tpl


def generate_header_md(entry, doc):
    doc.new_header(level=1, title="%s (%s)" % (entry["name"], entry["language"]))
    doc.write(entry["docs"]["description"], wrap_width=9999999999)


def generate_setup_md(entry, doc):
    doc.new_header(level=2, title="Setup")
    doc.insert_code("require'lspconfig'.%s.setup{}" % entry["name"], language="lua")

    if len(entry["default_config"]) > 0:
        doc.new_header(level=3, title="Default values")
        doc.insert_code(format_lua(entry["name"], entry["default_config"]), language="lua")

    cmds = []
    if type(entry["commands"]) is dict:
        items = sorted(list(entry["commands"].items()))
        for k, v in items:
            cmds.append("`%s`: %s" % (k.startswith(":") and k or ":%s" % k, v["description"]))

    if len(cmds) > 0:
        doc.new_header(level=2, title="Commands")
        doc.new_list(cmds)


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
                    settings.append("Default: `%s`" % (v["default"] == "vim.NIL" and "nil" or v["default"]))

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
