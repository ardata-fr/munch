# Tests for element_md applied to legend theme slots (legend.text, legend.title)

# --- legend.text with element_md ---

test_that("element_md on legend.text renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, color = factor(cyl))) +
    ggplot2::geom_point() +
    ggplot2::scale_color_discrete(
      labels = c("**4** cyl hey ho ho ho", "*6* cyl hey", "`8` cyl hey")
    ) +
    ggplot2::theme(legend.text = element_md())

  expect_no_error(print(p))
})

test_that("element_md on legend.text with fill aesthetic renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, fill = factor(cyl))) +
    ggplot2::geom_point(shape = 21) +
    ggplot2::scale_fill_discrete(
      labels = c("**Four**", "*Six*", "`Eight`")
    ) +
    ggplot2::theme(legend.text = element_md())

  expect_no_error(print(p))
})

test_that("element_md on legend.text with plain labels renders without error", {
  # Plain labels should still render correctly with element_md
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, color = factor(cyl))) +
    ggplot2::geom_point() +
    ggplot2::theme(legend.text = element_md())

  expect_no_error(print(p))
})

# --- legend.title with element_md ---

test_that("element_md on legend.title renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, color = factor(cyl))) +
    ggplot2::geom_point() +
    ggplot2::labs(color = "**Cylinders**") +
    ggplot2::theme(legend.title = element_md())

  expect_no_error(print(p))
})

test_that("element_md on legend.title with italic renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, color = wt)) +
    ggplot2::geom_point() +
    ggplot2::labs(color = "*Weight* (tons)") +
    ggplot2::theme(legend.title = element_md())

  expect_no_error(print(p))
})

# --- legend.text and legend.title together ---

test_that("element_md on both legend.text and legend.title renders without error", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt, color = factor(cyl))) +
    ggplot2::geom_point() +
    ggplot2::labs(color = "**Cylinders**") +
    ggplot2::scale_color_discrete(
      labels = c("**4** cyl", "*6* cyl", "`8` cyl")
    ) +
    ggplot2::theme(
      legend.title = element_md(),
      legend.text = element_md()
    )

  expect_no_error(print(p))
})

# --- element_grob called with legend-like parameters ---

test_that("element_grob.element_md with legend-like call (no margin_x/margin_y) works", {
  el <- element_md(size = 11)
  # Legend text grobs are called without margin_x/margin_y (both default FALSE)
  result <- ggplot2::element_grob(
    el,
    label = "**Bold** label",
    margin_x = FALSE,
    margin_y = FALSE
  )

  expect_s3_class(result, "mdTitleGrob")
})

test_that("element_grob.element_md produces absolute dimensions for legend label", {
  el <- element_md(size = 11)
  result <- ggplot2::element_grob(
    el,
    label = "**4** cyl",
    margin_x = FALSE,
    margin_y = FALSE
  )

  w <- grid::widthDetails(result)
  h <- grid::heightDetails(result)
  # Must be absolute (inches), not relative (null/npc), so ggplot2 can
  # size the legend panel correctly without squeezing out the plot area.
  expect_equal(grid::unitType(w), "inches")
  expect_equal(grid::unitType(h), "inches")
  expect_gt(grid::convertWidth(w, "inches", valueOnly = TRUE), 0)
  expect_gt(grid::convertHeight(h, "inches", valueOnly = TRUE), 0)
})
