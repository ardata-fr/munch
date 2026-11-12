# Default Text Properties for Markdown Grobs

Returns a list of text properties used for rendering markdown text.
Default values are taken from
[`flextable::get_flextable_defaults()`](https://davidgohel.github.io/flextable/reference/get_flextable_defaults.html),
allowing integration with flextable's theming system while providing a
standalone API for munch.

## Usage

``` r
default_text_props(
  font_size = NULL,
  font_family = NULL,
  font_color = NULL,
  code_font_family = NULL,
  line_spacing = NULL,
  img_baseline_ratio = NULL,
  bold = NULL,
  italic = NULL
)
```

## Arguments

- font_size:

  Font size in points.

- font_family:

  Font family name for regular text.

- font_color:

  Text color.

- code_font_family:

  Font family name for inline code (backticks). Defaults to `"mono"`.

- line_spacing:

  Line spacing, a multiple of the single line spacing of the font, as in
  Word: the distance between the baselines of two lines is
  `line_spacing` times the line height of the font
  ([`gdtools::font_line_metrics()`](https://davidgohel.github.io/gdtools/reference/font_line_metrics.html)).

- img_baseline_ratio:

  Controls vertical alignment of inline images. Specifies the proportion
  of the image height that appears below the text baseline:

  - `0`: image bottom at baseline

  - `0.15`: (default) similar to text descent proportions

  - `0.35`: image centered on text vertical center

  - `0.5`: image centered on baseline

- bold, italic:

  If `TRUE`, the text is bold or italic by default; markdown emphasis
  adds to it. Default `FALSE`.

## Value

A list of class `"text_props"` with elements:

- `font.size`: Font size in points

- `font.family`: Font family name

- `font.color`: Text color

- `code.font.family`: Font family for code

- `line_spacing`: Line height multiplier

- `img_baseline_ratio`: Image baseline alignment ratio

- `bold`, `italic`: default font face of the text

Some element names use dot separators (`font.size`, `font.family`, etc.)
for compatibility with 'flextable' conventions. Function parameters and
newer elements use snake_case (`line_spacing`, `img_baseline_ratio`)
which is the preferred convention going forward.

## Details

When arguments are `NULL` (the default), values are inherited from
[`flextable::get_flextable_defaults()`](https://davidgohel.github.io/flextable/reference/get_flextable_defaults.html).
This allows users to either:

1.  Use munch independently by specifying all properties:

        props <- default_text_props(font_size = 12, font_family = "serif")
        md_grob("**bold**", text_props = props)

2.  Use flextable's theming system:

        flextable::set_flextable_defaults(font.size = 14)
        md_grob("**bold**")

## Examples

``` r
library(grid)


# Get current defaults
default_text_props()
#> 
#> ── Text properties 
#> • font_size: 11
#> • font_family: "DejaVu Sans"
#> • font_color: "black"
#> • code_font_family: "mono"
#> • line_spacing: 1
#> • img_baseline_ratio: 0.15
#> • bold: FALSE
#> • italic: FALSE

# Override specific properties
default_text_props(font_size = 14, font_color = "navy")
#> 
#> ── Text properties 
#> • font_size: 14
#> • font_family: "DejaVu Sans"
#> • font_color: "navy"
#> • code_font_family: "mono"
#> • line_spacing: 1
#> • img_baseline_ratio: 0.15
#> • bold: FALSE
#> • italic: FALSE

library(gdtools)
font_set_liberation()
#> Font set
#>   sans:    Liberation Sans [liberation]
#>   serif:   Liberation Serif [liberation]
#>   mono:    Liberation Mono [liberation]
#>   symbol:  Liberation Sans [liberation]
#>   4 HTML dependencies

# Specify a monospace font for inline code
props <- default_text_props(
  font_family = "Liberation Sans",
  code_font_family = "Liberation Mono"
)

if (require(ggiraph, quietly = TRUE)) {
  x <- girafe(
    width_svg = 2,
    height_svg = 1,
    bg = "wheat",
    options = list(opts_sizing(rescale = FALSE)),
    code = {
      grid.newpage()
      gr <- md_grob("Text with `inline code`", text_props = props)
      grid.draw(gr)
    },
    dependencies = list(
      liberationsansHtmlDependency(),
      liberationmonoHtmlDependency()
    )
  )

  print(x)
}
```
