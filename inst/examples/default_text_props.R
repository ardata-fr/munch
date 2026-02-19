library(grid)


# Get current defaults
default_text_props()

# Override specific properties
default_text_props(font_size = 14, font_color = "navy")

library(gdtools)
font_set_liberation()

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
