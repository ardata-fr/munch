# Create a Grob from flextable Chunks

Creates a grob directly from flextable chunk data.frames (created with
[`flextable::as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.html)),
bypassing markdown parsing.

## Usage

``` r
chunks_grob(
  chunks,
  x = 0.5,
  y = 0.5,
  hjust = 0.5,
  vjust = 0.5,
  width = NULL,
  line_spacing = 1.2,
  img_baseline_ratio = 0.15,
  name = NULL
)
```

## Arguments

- chunks:

  A chunk data.frame from flextable (e.g., from
  [`flextable::as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.html)).

- x:

  X position (0-1 in npc units).

- y:

  Y position (0-1 in npc units).

- hjust:

  Horizontal justification.

- vjust:

  Vertical justification.

- width:

  Maximum width in inches (NULL for no wrapping).

- line_spacing:

  Line height multiplier.

- img_baseline_ratio:

  Controls vertical alignment of inline images. Specifies the proportion
  of the image height below the text baseline: `0` = bottom at baseline,
  `0.15` = default, `0.35` = centered on text, `0.5` = centered on
  baseline.

- name:

  Grob name.

## Value

A grob of class "mdGrob".

## Examples

``` r
#
library(grid)
library(flextable)
library(ggiraph)

library(gdtools)
#> 
#> Attaching package: ‘gdtools’
#> The following object is masked from ‘package:ggiraph’:
#> 
#>     match_family
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

chunks <- as_paragraph(
  as_chunk("E = mc"),
  as_sup("2")
)
gr <- chunks_grob(chunks)

x <- girafe(
  width_svg = 1,
  height_svg = 1,
  bg = "wheat",
  options = list(opts_sizing(rescale = FALSE)),
  code = {
    grid.newpage()
    grid.draw(gr)
  },
  dependencies = list(
    liberationsansHtmlDependency()
  )
)

x

{"x":{"html":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='ggiraph-svg' role='graphics-document' id='svg_ac96cb3ee4656e2e' viewBox='0 0 72 72'>\n <defs id='svg_ac96cb3ee4656e2e_defs'>\n  <clipPath id='svg_ac96cb3ee4656e2e_c1'>\n   <rect x='0' y='0' width='72' height='72'/>\n  <\/clipPath>\n <\/defs>\n <g id='svg_ac96cb3ee4656e2e_rootg' class='ggiraph-svg-rootg'>\n  <g clip-path='url(#svg_ac96cb3ee4656e2e_c1)'>\n   <rect x='0' y='0' width='72' height='72' fill='#F5DEB3' fill-opacity='1' stroke='#F5DEB3' stroke-opacity='1' stroke-width='0.75' stroke-linejoin='round' stroke-linecap='round' class='ggiraph-svg-bg'/>\n   <text x='14.66' y='39.46' font-size='9pt' font-family='Liberation Sans'>E<\/text>\n   <text x='26' y='39.46' font-size='9pt' font-family='Liberation Sans'>=<\/text>\n   <text x='36.34' y='39.46' font-size='9pt' font-family='Liberation Sans'>mc<\/text>\n   <text x='52.34' y='35.5' font-size='6.75pt' font-family='Liberation Sans'>2<\/text>\n  <\/g>\n <\/g>\n<\/svg>","js":null,"uid":"svg_ac96cb3ee4656e2e","ratio":1,"settings":{"tooltip":{"css":".tooltip_SVGID_ { padding:5px;background:black;color:white;border-radius:2px;text-align:left; ; position:absolute;pointer-events:none;z-index:9999;}","placement":"doc","opacity":0.9,"offx":10,"offy":10,"use_cursor_pos":true,"use_fill":false,"use_stroke":false,"delay_over":200,"delay_out":500},"hover":{"css":".hover_data_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_data_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_data_SVGID_ { fill:orange;stroke:black; }\nline.hover_data_SVGID_, polyline.hover_data_SVGID_ { fill:none;stroke:orange; }\nrect.hover_data_SVGID_, polygon.hover_data_SVGID_, path.hover_data_SVGID_ { fill:orange;stroke:none; }\nimage.hover_data_SVGID_ { stroke:orange; }","reactive":true,"nearest_distance":null,"linked":false},"hover_inv":{"css":""},"hover_key":{"css":".hover_key_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_key_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_key_SVGID_ { fill:orange;stroke:black; }\nline.hover_key_SVGID_, polyline.hover_key_SVGID_ { fill:none;stroke:orange; }\nrect.hover_key_SVGID_, polygon.hover_key_SVGID_, path.hover_key_SVGID_ { fill:orange;stroke:none; }\nimage.hover_key_SVGID_ { stroke:orange; }","reactive":true},"hover_theme":{"css":".hover_theme_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_theme_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_theme_SVGID_ { fill:orange;stroke:black; }\nline.hover_theme_SVGID_, polyline.hover_theme_SVGID_ { fill:none;stroke:orange; }\nrect.hover_theme_SVGID_, polygon.hover_theme_SVGID_, path.hover_theme_SVGID_ { fill:orange;stroke:none; }\nimage.hover_theme_SVGID_ { stroke:orange; }","reactive":true},"select":{"css":".select_data_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_data_SVGID_ { stroke:none;fill:red; }\ncircle.select_data_SVGID_ { fill:red;stroke:black; }\nline.select_data_SVGID_, polyline.select_data_SVGID_ { fill:none;stroke:red; }\nrect.select_data_SVGID_, polygon.select_data_SVGID_, path.select_data_SVGID_ { fill:red;stroke:none; }\nimage.select_data_SVGID_ { stroke:red; }","type":"multiple","only_shiny":true,"selected":[],"linked":false},"select_inv":{"css":""},"select_key":{"css":".select_key_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_key_SVGID_ { stroke:none;fill:red; }\ncircle.select_key_SVGID_ { fill:red;stroke:black; }\nline.select_key_SVGID_, polyline.select_key_SVGID_ { fill:none;stroke:red; }\nrect.select_key_SVGID_, polygon.select_key_SVGID_, path.select_key_SVGID_ { fill:red;stroke:none; }\nimage.select_key_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"select_theme":{"css":".select_theme_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_theme_SVGID_ { stroke:none;fill:red; }\ncircle.select_theme_SVGID_ { fill:red;stroke:black; }\nline.select_theme_SVGID_, polyline.select_theme_SVGID_ { fill:none;stroke:red; }\nrect.select_theme_SVGID_, polygon.select_theme_SVGID_, path.select_theme_SVGID_ { fill:red;stroke:none; }\nimage.select_theme_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"zoom":{"min":1,"max":1,"duration":300,"default_on":false},"toolbar":{"position":"topright","pngname":"diagram","tooltips":null,"fixed":false,"hidden":[],"delay_over":200,"delay_out":500},"sizing":{"rescale":false,"width":1}}},"evals":[],"jsHooks":[]}
init_flextable_defaults()
```
