# Text with a wrapping width, for each hjust: the text must stay at its
# anchor (red lines) and inside the box of the label.
df <- expand.grid(
  hjust = c(0, 0.5, 1),
  label = c("Hello **world**", "Hello **world**, this text wraps on two lines"),
  stringsAsFactors = FALSE
)
df$x <- c(0.1, 0.5, 0.9)[match(df$hjust, c(0, 0.5, 1))]
df$y <- ifelse(grepl("wraps", df$label), 0.15, 0.4)
df_label <- df
df_label$y <- df_label$y + 0.5

list(
  plot = ggplot2::ggplot(df, ggplot2::aes(x, y, label = label, hjust = hjust)) +
    ggplot2::geom_vline(
      xintercept = c(0.1, 0.5, 0.9),
      colour = "red",
      linewidth = 0.3
    ) +
    geom_text_md(width = 1, size = 4) +
    geom_label_md(
      data = df_label,
      width = 1,
      size = 4,
      label.padding = ggplot2::unit(0.5, "lines")
    ) +
    ggplot2::scale_x_continuous(limits = c(0, 1)) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    base_theme(),
  width = 7,
  height = 4
)
