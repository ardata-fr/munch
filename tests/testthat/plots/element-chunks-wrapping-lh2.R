chunks <- flextable::as_paragraph(
  flextable::as_chunk("Source: Motor Trend US magazine (1974). "),
  flextable::as_chunk(
    "The data was extracted from the 1974 edition and comprises fuel consumption."
  ),
  flextable::as_chunk(
    " Variables include miles per gallon, cylinders, and weight."
  )
)

list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    base_theme() +
    ggplot2::theme(plot.caption = element_chunks(chunks, lineheight = 2)),
  width = 4
)
