# geom_text_md tests --------------------------------------------------------

test_that("geom_text_md creates a ggplot layer", {
  df <- data.frame(x = 1, y = 1, label = "**Bold**")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md()

  expect_s3_class(p, "ggplot")
  expect_length(p$layers, 1)
  expect_s3_class(p$layers[[1]]$geom, "GeomTextMd")
})

test_that("geom_text_md renders without error", {
  df <- data.frame(
    x = 1:3,
    y = 1:3,
    label = c("**Bold**", "*Italic*", "`Code`")
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md()

  grob <- ggplot2::ggplotGrob(p)
  expect_s3_class(grob, "gtable")
})

test_that("geom_text_md accepts mm and pt size units", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label))

  # Should not error with mm (default)
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_text_md(size = 10, size.unit = "mm"))
  )

  # Should not error with pt
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_text_md(size = 10, size.unit = "pt"))
  )

  # Should not error with other valid units
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_text_md(size = 1, size.unit = "cm"))
  )
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_text_md(size = 0.5, size.unit = "in"))
  )
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_text_md(size = 10, size.unit = "pc"))
  )
})

test_that("geom_text_md rejects invalid size.unit", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label))

  expect_error(
    ggplot2::ggplotGrob(
      p + geom_text_md(size = 10, size.unit = "invalid")
    ),
    "arg"
  )
})

test_that("geom_text_md handles width parameter for wrapping", {
  df <- data.frame(x = 1, y = 1, label = "This is **long** text")

  p_no_wrap <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md()
  p_wrap <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md(width = 0.5)

  # Both should render
  expect_no_error(ggplot2::ggplotGrob(p_no_wrap))
  expect_no_error(ggplot2::ggplotGrob(p_wrap))
})

test_that("geom_text_md handles lineheight aesthetic", {
  df <- data.frame(x = 1:2, y = 1:2, label = "A\n\nB", lh = c(1.0, 2.0))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label, lineheight = lh)) +
    geom_text_md()

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_text_md handles all aesthetics", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md(
      colour = "red",
      size = 5,
      angle = 45,
      hjust = 0,
      vjust = 1,
      alpha = 0.5,
      family = "sans",
      lineheight = 1.5
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_text_md handles empty data", {
  df <- data.frame(x = numeric(0), y = numeric(0), label = character(0))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md() +
    ggplot2::xlim(0, 1) +
    ggplot2::ylim(0, 1)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_text_md handles NA labels", {
  df <- data.frame(x = 1:3, y = 1:3, label = c("**A**", NA, "`C`"))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md(na.rm = TRUE)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_text_md handles markdown formatting", {
  df <- data.frame(
    x = 1:5,
    y = 1:5,
    label = c("**bold**", "*italic*", "`code`", "~~strike~~", "normal")
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_text_md()

  expect_no_error(ggplot2::ggplotGrob(p))
})

# geom_label_md tests -------------------------------------------------------

test_that("geom_label_md creates a ggplot layer", {
  df <- data.frame(x = 1, y = 1, label = "**Bold**")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md()

  expect_s3_class(p, "ggplot")
  expect_length(p$layers, 1)
  expect_s3_class(p$layers[[1]]$geom, "GeomLabelMd")
})

test_that("geom_label_md renders without error", {
  df <- data.frame(
    x = 1:3,
    y = 1:3,
    label = c("**Bold**", "*Italic*", "`Code`")
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md()

  grob <- ggplot2::ggplotGrob(p)
  expect_s3_class(grob, "gtable")
})

test_that("geom_label_md handles fill aesthetic", {
  df <- data.frame(x = 1:3, y = 1:3, label = c("A", "B", "C"))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(fill = "lightyellow")

  expect_no_error(ggplot2::ggplotGrob(p))

  # With mapped fill
  p2 <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label, fill = label)) +
    geom_label_md()

  expect_no_error(ggplot2::ggplotGrob(p2))
})

test_that("geom_label_md handles label.* parameters", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(
      label.padding = grid::unit(0.5, "lines"),
      label.r = grid::unit(0.3, "lines"),
      label.size = 0.5
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md handles label.size = 0 (no border)", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(label.size = 0)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md accepts mm and pt size units", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label))

  expect_no_error(
    ggplot2::ggplotGrob(p + geom_label_md(size = 10, size.unit = "mm"))
  )
  expect_no_error(
    ggplot2::ggplotGrob(p + geom_label_md(size = 10, size.unit = "pt"))
  )
})

test_that("geom_label_md rejects invalid size.unit", {
  df <- data.frame(x = 1, y = 1, label = "**Test**")
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label))

  expect_error(
    ggplot2::ggplotGrob(
      p + geom_label_md(size = 10, size.unit = "npc")
    ),
    "arg"
  )
})

test_that("geom_label_md handles lineheight aesthetic", {
  df <- data.frame(x = 1, y = 1, label = "Line1\n\nLine2")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(ggplot2::aes(lineheight = 1.5))

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md handles width parameter", {
  df <- data.frame(x = 1, y = 1, label = "This is **long** text to wrap")

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(width = 1)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md handles empty data", {
  df <- data.frame(x = numeric(0), y = numeric(0), label = character(0))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md() +
    ggplot2::xlim(0, 1) +
    ggplot2::ylim(0, 1)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md handles NA labels", {
  df <- data.frame(x = 1:3, y = 1:3, label = c("**A**", NA, "`C`"))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(na.rm = TRUE)

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_label_md handles rotation", {
  df <- data.frame(x = 1:3, y = 1, label = "**Test**", angle = c(0, 45, 90))

  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, label = label)) +
    geom_label_md(angle = df$angle)

  expect_no_error(ggplot2::ggplotGrob(p))
})

# resolve_text_unit tests ---------------------------------------------------

test_that("resolve_text_unit returns correct multipliers", {
  expect_equal(munch:::resolve_text_unit("pt"), 1)
  expect_equal(munch:::resolve_text_unit("mm"), ggplot2::.pt)
  expect_equal(munch:::resolve_text_unit("in"), 72.27)
  expect_equal(munch:::resolve_text_unit("pc"), 12)
  expect_equal(munch:::resolve_text_unit("cm"), ggplot2::.pt * 10)
})

test_that("resolve_text_unit errors on invalid unit", {
  expect_error(munch:::resolve_text_unit("invalid"), "arg")
  expect_error(munch:::resolve_text_unit("npc"), "arg")
  expect_error(munch:::resolve_text_unit(""), "arg")
})

# Default aesthetics tests --------------------------------------------------

test_that("GeomTextMd has correct default aesthetics", {
  defaults <- GeomTextMd$default_aes

  expect_equal(defaults$colour, "black")
  expect_equal(defaults$size, 3.88)
  expect_equal(defaults$angle, 0)
  expect_equal(defaults$hjust, 0.5)
  expect_equal(defaults$vjust, 0.5)
  expect_true(is.na(defaults$alpha))
  expect_equal(defaults$family, "")
  expect_equal(defaults$lineheight, 1)
})

test_that("GeomLabelMd has correct default aesthetics", {
  defaults <- GeomLabelMd$default_aes

  expect_equal(defaults$colour, "black")
  expect_equal(defaults$fill, "white")
  expect_equal(defaults$size, 3.88)
  expect_equal(defaults$angle, 0)
  expect_equal(defaults$hjust, 0.5)
  expect_equal(defaults$vjust, 0.5)
  expect_true(is.na(defaults$alpha))
  expect_equal(defaults$family, "")
  expect_equal(defaults$lineheight, 1)
})

test_that("GeomTextMd has correct required aesthetics", {
  expect_equal(GeomTextMd$required_aes, c("x", "y", "label"))
})

test_that("GeomLabelMd has correct required aesthetics", {
  expect_equal(GeomLabelMd$required_aes, c("x", "y", "label"))
})

# element_chunks tests -------------------------------------------------------

test_that("element_chunks creates correct class", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("H"),
    flextable::as_sub("2"),
    flextable::as_chunk("O")
  )
  el <- element_chunks(chunks)

  expect_s3_class(el, "element_chunks")
  expect_s3_class(el, "element_text")
  expect_s3_class(el, "element")
})
test_that("element_chunks stores chunks", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("Test")
  )
  el <- element_chunks(chunks)

  expect_true("chunks" %in% names(el))
  expect_s3_class(el$chunks, "paragraph")
})

test_that("element_chunks rejects invalid input", {
  expect_error(
    element_chunks("not a chunk"),
    "must be a paragraph or chunk"
  )
  expect_error(
    element_chunks(123),
    "must be a paragraph or chunk"
  )
})

test_that("element_chunks renders in ggplot without error", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("R"),
    flextable::as_sup("2"),
    flextable::as_chunk(" = 0.75")
  )

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::theme(
      plot.caption = element_chunks(chunks)
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("element_chunks works with subscripts", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("H"),
    flextable::as_sub("2"),
    flextable::as_chunk("O")
  )

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::theme(
      plot.caption = element_chunks(chunks)
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("element_chunks works with superscripts", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("E = mc"),
    flextable::as_sup("2")
  )

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::theme(
      plot.title = element_chunks(chunks)
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("element_chunks works with colored text", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("Normal "),
    flextable::colorize(flextable::as_chunk("Red"), color = "red")
  )

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::theme(
      plot.subtitle = element_chunks(chunks)
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("element_chunks accepts hjust and vjust", {
  chunks <- flextable::as_paragraph(flextable::as_chunk("Test"))

  el <- element_chunks(chunks, hjust = 0, vjust = 1)

  expect_equal(el$hjust, 0)
  expect_equal(el$vjust, 1)
})

test_that("element_chunks accepts angle", {
  chunks <- flextable::as_paragraph(flextable::as_chunk("Test"))

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    ggplot2::theme(
      plot.caption = element_chunks(chunks, angle = 45)
    )

  expect_no_error(ggplot2::ggplotGrob(p))
})
