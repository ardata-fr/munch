df <- data.frame(
  x = c(1, 2, 3),
  y = c(3, 2, 1),
  label = c("**Bold text**", "*Italic text*", "`Code text`")
)

list(
  plot = ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md(size = 5) +
    ggplot2::xlim(0.5, 3.5) +
    ggplot2::ylim(0.5, 3.5) +
    base_theme()
)
