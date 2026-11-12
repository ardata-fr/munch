# equations in theme elements: inline, a fraction that makes its line
# higher, the colour and the size of the chunk
red <- officer::fp_text_lite(color = "#C0392B", font.size = 16)

title_chunks <- flextable::as_paragraph(
  flextable::as_chunk("Area of a disc: "),
  flextable::as_equation("A = \\pi r^2"),
  flextable::as_chunk(", ratio "),
  flextable::as_equation("\\frac{a+b}{c}")
)

caption_chunks <- flextable::as_paragraph(
  flextable::as_chunk("Mean ", props = red),
  flextable::as_equation("\\bar{x} = \\frac{1}{n}\\sum_{i=1}^n x_i", props = red)
)

list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    base_theme() +
    ggplot2::theme(
      plot.title = element_chunks(title_chunks),
      plot.caption = element_chunks(caption_chunks)
    ),
  width = 6,
  height = 4
)
