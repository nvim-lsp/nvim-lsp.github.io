# website

A website for lsp-mode

## Usage

This site is built using mkdocs, which requires `python` and `pip`.

```
pip install mdutils
pip install mkdocs-material
```

Then generate the documentation with:

```
./scripts/docgen.sh
```

Now you have documentation in `site/`.

## Development

To serve a development version run the following after generation:

```
mkdocs serve
```
