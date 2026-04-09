# Convert Markdown to a Paragraph Object

Converts a markdown string to a paragraph object compatible with
flextable. This allows using markdown syntax to format text in flextable
cells.

## Usage

``` r
as_paragraph_md(x, font_family_mono = "mono")
```

## Arguments

- x:

  A character string containing markdown.

- font_family_mono:

  Font family to use for inline code. Defaults to `"mono"`.

## Value

A paragraph object (class `"paragraph"`) that can be used with
[`flextable::mk_par()`](https://davidgohel.github.io/flextable/reference/compose.html)
or
[`flextable::as_flextable()`](https://davidgohel.github.io/flextable/reference/as_flextable.html).

## Details

Supported markdown syntax:

- `**bold**` or `__bold__`

- `*italic*` or `_italic_`

- `` `code` `` (monospace)

- `~~strikethrough~~`

- `[link](url)` (underlined and colored)

- `![alt](path)` (images)

- Line breaks with `\n\n` (paragraph) or two spaces + `\n` (hard break)

## Examples

``` r
library(flextable)

ft <- flextable(head(iris, 3))
ft <- mk_par(
  ft,
  j = 1,
  part = "body",
  value = as_paragraph_md("**Column1** has *values*")
)
ft


.cl-61878cce{}.cl-617f147c{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-617f14cc{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-617f14d6{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:italic;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-6182acc2{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6182accc{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6182e124{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6182e12e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6182e138{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6182e142{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6182e143{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-6182e144{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```

Sepal.Width

Petal.Length

Petal.Width

Species

Column1 has values

3.5

1.4

0.2

setosa

Column1 has values

3.0

1.4

0.2

setosa

Column1 has values

3.2

1.3

0.2

setosa

\# With inline code ft \<-
[mk_par](https://davidgohel.github.io/flextable/reference/compose.html)(
ft, j = 2, part = "body", value = as_paragraph_md("Use \`Sepal.Width\`
column") ) ft

| Sepal.Length       | Sepal.Width            | Petal.Length | Petal.Width | Species |
|--------------------|------------------------|--------------|-------------|---------|
| Column1 has values | Use Sepal.Width column | 1.4          | 0.2         | setosa  |
| Column1 has values | Use Sepal.Width column | 1.4          | 0.2         | setosa  |
| Column1 has values | Use Sepal.Width column | 1.3          | 0.2         | setosa  |
