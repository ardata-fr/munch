r_logo <- file.path(R.home("doc"), "html", "logo.jpg")

dat <- subset(ggplot2::diamonds, cut %in% c("Premium", "Ideal"))

title_chunks <- flextable::as_paragraph(
  flextable::as_image(src = r_logo, width = 0.25, height = 0.2),
  flextable::as_chunk(" "),
  flextable::as_b("Diamond"),
  flextable::as_chunk(" pricing \u2014 "),
  flextable::as_i("Premium"),
  flextable::as_chunk(" vs "),
  flextable::as_i("Ideal")
)

subtitle_chunks <- flextable::as_paragraph(
  flextable::colorize("Premium", color = "#E31A1C"),
  flextable::as_chunk(" (n = "),
  flextable::as_highlight(
    as.character(sum(dat$cut == "Premium")),
    color = "#FDDBC7"
  ),
  flextable::as_chunk(") and "),
  flextable::colorize("Ideal", color = "#1F78B4"),
  flextable::as_chunk(" (n = "),
  flextable::as_highlight(
    as.character(sum(dat$cut == "Ideal")),
    color = "#D1E5F0"
  ),
  flextable::as_chunk(")")
)

caption_chunks <- flextable::as_paragraph(
  flextable::as_chunk("R"),
  flextable::as_sup("2"),
  flextable::as_chunk(" = 0.85 \u00b7 "),
  flextable::as_strike("no effect"),
  flextable::as_chunk(" \u00b7 H"),
  flextable::as_sub("0"),
  flextable::as_chunk(" rejected")
)

ylab_chunks <- flextable::as_paragraph(
  flextable::as_chunk(
    "Price",
    props = officer::fp_text_lite(bold = TRUE, color = "#2C3E50")
  ),
  flextable::as_chunk(" (USD)")
)

xlab_chunks <- flextable::as_paragraph(
  flextable::as_chunk(
    "Carat",
    props = officer::fp_text_lite(bold = TRUE, color = "#2C3E50")
  ),
  flextable::as_chunk(" weight")
)

list(
  plot = ggplot2::ggplot(dat, ggplot2::aes(carat, price, color = cut)) +
    ggplot2::geom_point(alpha = 0.05, size = 0.5) +
    ggplot2::geom_smooth(
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      linewidth = 1.2
    ) +
    ggplot2::scale_color_manual(
      values = c(Premium = "#E31A1C", Ideal = "#1F78B4")
    ) +
    base_theme() +
    ggplot2::theme(
      plot.title = element_chunks(title_chunks),
      plot.subtitle = element_chunks(subtitle_chunks),
      plot.caption = element_chunks(caption_chunks),
      axis.title.x = element_chunks(xlab_chunks),
      axis.title.y = element_chunks(ylab_chunks)
    ),
  width = 6,
  height = 5
)
