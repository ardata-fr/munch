library(grid)

library(gdtools)
font_set_liberation()
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
