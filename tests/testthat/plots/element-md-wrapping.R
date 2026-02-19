list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(
      title = paste(
        "This is a **very long title** that should *automatically wrap*",
        "when rendered because it exceeds the available plot width",
        "and `element_md()` supports auto-wrapping"
      )
    ) +
    base_theme() +
    ggplot2::theme(plot.title = element_md()),
  width = 4
)
