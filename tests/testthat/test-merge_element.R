# --- merge_element() of element_md ---

test_that("merge_element() of element_md inherits from element_text", {
  old <- ggplot2::element_text(
    size = 14,
    colour = "red",
    family = "serif",
    hjust = 0.5
  )
  new <- element_md(size = 20)

  result <- ggplot2::merge_element(new, old)

  expect_s3_class(result, "element_md")
  expect_equal(result$size, 20)
  expect_equal(result$colour, "red")
  expect_equal(result$family, "serif")
  expect_equal(result$hjust, 0.5)
})

test_that("merge_element() of element_md keeps new values over old", {
  old <- ggplot2::element_text(colour = "blue", size = 10)
  new <- element_md(colour = "green", size = 16)

  result <- ggplot2::merge_element(new, old)

  expect_equal(result$colour, "green")
  expect_equal(result$size, 16)
})

test_that("merge_element() of element_md fills all NULL slots", {
  old <- ggplot2::element_text(
    family = "sans",
    face = "bold",
    colour = "black",
    size = 12,
    hjust = 0,
    vjust = 1,
    angle = 0,
    lineheight = 1.2,
    margin = ggplot2::margin(2, 2, 2, 2)
  )
  new <- element_md()

  result <- ggplot2::merge_element(new, old)

  expect_equal(result$family, "sans")
  expect_equal(result$face, "bold")
  expect_equal(result$colour, "black")
  expect_equal(result$size, 12)
  expect_equal(result$hjust, 0)
  expect_equal(result$vjust, 1)
  expect_equal(result$angle, 0)
  expect_equal(result$lineheight, 1.2)
  expect_equal(result$margin, ggplot2::margin(2, 2, 2, 2))
})

test_that("merge_element() of element_md preserves code_font_family", {
  old <- ggplot2::element_text(size = 12)
  new <- element_md(code_font_family = "Liberation Mono")

  result <- ggplot2::merge_element(new, old)

  expect_equal(result$code_font_family, "Liberation Mono")
  expect_equal(result$size, 12)
})

test_that("merge_element() of element_md with element_md as old", {
  old <- element_md(
    family = "sans",
    code_font_family = "mono",
    size = 10,
    colour = "gray"
  )
  new <- element_md(size = 14)

  result <- ggplot2::merge_element(new, old)

  expect_s3_class(result, "element_md")
  expect_equal(result$size, 14)
  expect_equal(result$family, "sans")
  expect_equal(result$code_font_family, "mono")
  expect_equal(result$colour, "gray")
})

test_that("merge_element() of element_md returns element_md class", {
  old <- ggplot2::element_text(size = 12)
  new <- element_md()

  result <- ggplot2::merge_element(new, old)

  expect_s3_class(result, "element_md")
  expect_s3_class(result, "element_text")
  expect_s3_class(result, "element")
})

# --- merge_element() of element_chunks ---

test_that("merge_element() of element_chunks inherits from element_text", {
  old <- ggplot2::element_text(
    hjust = 0.5,
    vjust = 1,
    angle = 45,
    lineheight = 1.5,
    margin = ggplot2::margin(5, 5, 5, 5)
  )
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )
  new <- element_chunks(chunks = chunks_obj)

  result <- ggplot2::merge_element(new, old)

  expect_s3_class(result, "element_chunks")
  expect_equal(result$hjust, 0.5)
  expect_equal(result$vjust, 1)
  expect_equal(result$angle, 45)
  expect_equal(result$lineheight, 1.5)
  expect_equal(result$margin, ggplot2::margin(5, 5, 5, 5))
})

test_that("merge_element() of element_chunks keeps new values over old", {
  old <- ggplot2::element_text(hjust = 0, vjust = 0)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )
  new <- element_chunks(chunks = chunks_obj, hjust = 1, vjust = 0.5)

  result <- ggplot2::merge_element(new, old)

  expect_equal(result$hjust, 1)
  expect_equal(result$vjust, 0.5)
})

test_that("merge_element() of element_chunks preserves chunks", {
  old <- ggplot2::element_text(size = 12)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("hello")
  )
  new <- element_chunks(chunks = chunks_obj)

  result <- ggplot2::merge_element(new, old)

  expect_identical(result$chunks, chunks_obj)
})

test_that("merge_element() of element_chunks with element_chunks as old", {
  chunks1 <- flextable::as_paragraph(
    flextable::as_chunk("old")
  )
  chunks2 <- flextable::as_paragraph(
    flextable::as_chunk("new")
  )
  old <- element_chunks(chunks = chunks1, hjust = 0, lineheight = 1.2)
  new <- element_chunks(chunks = chunks2)

  result <- ggplot2::merge_element(new, old)

  expect_identical(result$chunks, chunks2)
  expect_equal(result$hjust, 0)
  expect_equal(result$lineheight, 1.2)
})

test_that("merge_element() of element_chunks returns element_chunks class", {
  old <- ggplot2::element_text(size = 12)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )
  new <- element_chunks(chunks = chunks_obj)

  result <- ggplot2::merge_element(new, old)

  expect_s3_class(result, "element_chunks")
  expect_s3_class(result, "element_text")
  expect_s3_class(result, "element")
})

test_that("munch elements are S7 elements of 'ggplot2'", {
  expect_true(S7::S7_inherits(element_md(), ggplot2::element_text))
  chunks <- flextable::as_paragraph(flextable::as_chunk("a"))
  expect_true(S7::S7_inherits(element_chunks(chunks), ggplot2::element_text))
  # ggplot2 reads their properties as those of its own elements
  el <- ggplot2::calc_element(
    "axis.text.theta",
    ggplot2::theme_grey() + ggplot2::theme(axis.text.theta = element_md())
  )
  expect_true(grid::is.unit(el@margin))
})

test_that("an element_md() parent is inherited by its children", {
  th <- ggplot2::theme_grey() + ggplot2::theme(axis.text = element_md())
  expect_s3_class(ggplot2::calc_element("axis.text.x", th), "element_md")
  expect_s3_class(ggplot2::calc_element("axis.text.y", th), "element_md")
})

test_that("element_md() can be the root element text", {
  withr::local_options(munch.skip_device_check = TRUE)
  th <- ggplot2::theme_grey() + ggplot2::theme(text = element_md())
  for (el in c("plot.title", "axis.text.x", "legend.title", "strip.text")) {
    expect_s3_class(ggplot2::calc_element(el, th), "element_md")
  }
  # legends merge an element_text() into the root to set their defaults
  merged <- ggplot2::merge_element(
    ggplot2::element_text(hjust = 0),
    element_md(code_font_family = "Courier", width = 2)
  )
  expect_s3_class(merged, "element_md")
  expect_identical(merged$hjust, 0)
  expect_identical(merged$code_font_family, "Courier")
  expect_identical(merged$width, 2)

  p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg, colour = hp)) +
    ggplot2::geom_point(ggplot2::aes(shape = factor(cyl))) +
    ggplot2::labs(title = "**Bold** title") +
    th
  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("NULL and NA are unset values of code_font_family and width", {
  expect_identical(element_md()$width, NA_real_)
  expect_identical(element_md(width = NULL)$width, NA_real_)
  expect_identical(element_md(code_font_family = NULL)$code_font_family, NA_character_)
  # an unset value is taken from the element inherited from
  merged <- ggplot2::merge_element(element_md(), element_md(width = 2, code_font_family = "Courier"))
  expect_identical(merged$width, 2)
  expect_identical(merged$code_font_family, "Courier")
})
