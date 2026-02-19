list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(title = "**Bold title** with *italic* and `code`") +
    base_theme() +
    ggplot2::theme(plot.title = element_md())
)
