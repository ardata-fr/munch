# superscripts and subscripts of Pandoc markdown, with a strikethrough and
# formatting inside a script
list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(
      title = "CO~2~ emissions in m^3^ per km^2^",
      subtitle = "~~old~~ new: 2^10^ = 1024, x~*i*~ and y^**j**^",
      caption = "Not scripts: x^2 and a~b"
    ) +
    base_theme() +
    ggplot2::theme(
      plot.title = element_md(),
      plot.subtitle = element_md(),
      plot.caption = element_md()
    ),
  width = 5,
  height = 4
)
