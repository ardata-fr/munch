df <- data.frame(
  x = c(1, 2),
  y = c(2, 1),
  label = c("**Bold** label", "*Italic* label")
)

list(
  plot = ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(size = 5) +
    ggplot2::xlim(0.5, 2.5) +
    ggplot2::ylim(0.5, 2.5) +
    base_theme()
)
