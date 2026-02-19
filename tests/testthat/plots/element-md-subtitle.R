list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(subtitle = "Using the `mtcars` dataset from **R**") +
    base_theme() +
    ggplot2::theme(plot.subtitle = element_md())
)
