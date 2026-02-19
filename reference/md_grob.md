# Create a Grob from Markdown Text

Parses markdown text and creates a grid grob that can be used in ggplot2
with
[`annotation_custom()`](https://ggplot2.tidyverse.org/reference/annotation_custom.html)
or directly with grid.

## Usage

``` r
md_grob(
  md_text,
  x = 0.5,
  y = 0.5,
  hjust = 0.5,
  vjust = 0.5,
  width = NULL,
  line_spacing = 1.2,
  text_props = NULL,
  name = NULL
)
```

## Arguments

- md_text:

  Character string with markdown formatting.

- x:

  X position (0-1 in npc units, default 0.5).

- y:

  Y position (0-1 in npc units, default 0.5).

- hjust:

  Horizontal justification (0=left, 0.5=center, 1=right).

- vjust:

  Vertical justification (0=bottom, 0.5=center, 1=top).

- width:

  Maximum width in inches (NULL for no wrapping).

- line_spacing:

  Line height multiplier (default 1.2).

- text_props:

  Text properties created with
  [`default_text_props()`](https://ardata-fr.github.io/munch/reference/default_text_props.md).
  If `NULL`, uses current defaults from
  [`flextable::get_flextable_defaults()`](https://davidgohel.github.io/flextable/reference/get_flextable_defaults.html).
  Use `img_baseline_ratio` in text_props to control image vertical
  alignment.

- name:

  Grob name (optional).

## Value

A grob of class "mdGrob".

## Examples

``` r
library(grid)

library(gdtools)
font_set_liberation()
#> Font set
#>   sans:    Liberation Sans [liberation]
#>   serif:   Liberation Serif [liberation]
#>   mono:    Liberation Mono [liberation]
#>   symbol:  Liberation Sans [liberation]
#>   4 HTML dependencies
flextable::set_flextable_defaults(
  font.size = 12,
  font.family = "Liberation Sans"
)

if (require(ggiraph, quietly = TRUE)) {
  x <- girafe(
    width_svg = 3,
    height_svg = 1,
    bg = "wheat",
    options = list(opts_sizing(rescale = FALSE)),
    code = {
      # Simple markdown (uses flextable defaults)
      gr <- md_grob("This is **bold** and *italic* text.")
      grid.newpage()
      grid.draw(gr)
    },
    dependencies = list(
      liberationsansHtmlDependency()
    )
  )

  print(x)

  x <- girafe(
    width_svg = 3,
    height_svg = 1,
    bg = "wheat",
    options = list(opts_sizing(rescale = FALSE)),
    code = {
      # Customize with text_props (standalone, no flextable dependency)
      props <- default_text_props(font_size = 14, font_color = "navy")
      gr2 <- md_grob("Code example: `print(x)`", text_props = props)
      grid.newpage()
      grid.draw(gr2)
    },
    dependencies = list(
      liberationsansHtmlDependency()
    )
  )

  print(x)
}
```
