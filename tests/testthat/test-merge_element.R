# --- merge_element.element_md ---

test_that("merge_element.element_md inherits from element_text", {
  old <- ggplot2::element_text(
    size = 14,
    colour = "red",
    family = "serif",
    hjust = 0.5
  )
  new <- element_md(size = 20)

  result <- munch:::merge_element.element_md(new, old)

  expect_s3_class(result, "element_md")
  expect_equal(result$size, 20)
  expect_equal(result$colour, "red")
  expect_equal(result$family, "serif")
  expect_equal(result$hjust, 0.5)
})

test_that("merge_element.element_md keeps new values over old", {
  old <- ggplot2::element_text(colour = "blue", size = 10)
  new <- element_md(colour = "green", size = 16)

  result <- munch:::merge_element.element_md(new, old)

  expect_equal(result$colour, "green")
  expect_equal(result$size, 16)
})

test_that("merge_element.element_md fills all NULL slots", {
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

  result <- munch:::merge_element.element_md(new, old)

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

test_that("merge_element.element_md preserves code_font_family", {
  old <- ggplot2::element_text(size = 12)
  new <- element_md(code_font_family = "Liberation Mono")

  result <- munch:::merge_element.element_md(new, old)

  expect_equal(result$code_font_family, "Liberation Mono")
  expect_equal(result$size, 12)
})

test_that("merge_element.element_md with element_md as old", {
  old <- element_md(
    family = "sans",
    code_font_family = "mono",
    size = 10,
    colour = "gray"
  )
  new <- element_md(size = 14)

  result <- munch:::merge_element.element_md(new, old)

  expect_s3_class(result, "element_md")
  expect_equal(result$size, 14)
  expect_equal(result$family, "sans")
  expect_equal(result$code_font_family, "mono")
  expect_equal(result$colour, "gray")
})

test_that("merge_element.element_md returns element_md class", {
  old <- ggplot2::element_text(size = 12)
  new <- element_md()

  result <- munch:::merge_element.element_md(new, old)

  expect_s3_class(result, "element_md")
  expect_s3_class(result, "element_text")
  expect_s3_class(result, "element")
})

# --- merge_element.element_chunks ---

test_that("merge_element.element_chunks inherits from element_text", {
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

  result <- munch:::merge_element.element_chunks(new, old)

  expect_s3_class(result, "element_chunks")
  expect_equal(result$hjust, 0.5)
  expect_equal(result$vjust, 1)
  expect_equal(result$angle, 45)
  expect_equal(result$lineheight, 1.5)
  expect_equal(result$margin, ggplot2::margin(5, 5, 5, 5))
})

test_that("merge_element.element_chunks keeps new values over old", {
  old <- ggplot2::element_text(hjust = 0, vjust = 0)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )
  new <- element_chunks(chunks = chunks_obj, hjust = 1, vjust = 0.5)

  result <- munch:::merge_element.element_chunks(new, old)

  expect_equal(result$hjust, 1)
  expect_equal(result$vjust, 0.5)
})

test_that("merge_element.element_chunks preserves chunks", {
  old <- ggplot2::element_text(size = 12)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("hello")
  )
  new <- element_chunks(chunks = chunks_obj)

  result <- munch:::merge_element.element_chunks(new, old)

  expect_identical(result$chunks, chunks_obj)
})

test_that("merge_element.element_chunks with element_chunks as old", {
  chunks1 <- flextable::as_paragraph(
    flextable::as_chunk("old")
  )
  chunks2 <- flextable::as_paragraph(
    flextable::as_chunk("new")
  )
  old <- element_chunks(chunks = chunks1, hjust = 0, lineheight = 1.2)
  new <- element_chunks(chunks = chunks2)

  result <- munch:::merge_element.element_chunks(new, old)

  expect_identical(result$chunks, chunks2)
  expect_equal(result$hjust, 0)
  expect_equal(result$lineheight, 1.2)
})

test_that("merge_element.element_chunks returns element_chunks class", {
  old <- ggplot2::element_text(size = 12)
  chunks_obj <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )
  new <- element_chunks(chunks = chunks_obj)

  result <- munch:::merge_element.element_chunks(new, old)

  expect_s3_class(result, "element_chunks")
  expect_s3_class(result, "element_text")
  expect_s3_class(result, "element")
})
