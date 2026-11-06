long_title <- paste(
  "Monthly **sales** by large commercial region with a *detailed* view",
  "by family of products that are sold"
)
y_labels <- function(x) {
  paste0(format(x * 1e6, big.mark = " ", scientific = FALSE), " EUR")
}
title_plot <- function(title_element = element_md(), ...) {
  ggplot2::ggplot(data.frame(x = 1:4, y = 1:4), ggplot2::aes(x, y)) +
    ggplot2::geom_col() +
    ggplot2::scale_y_continuous(labels = y_labels) +
    ggplot2::labs(title = long_title, x = NULL, y = NULL) +
    ggplot2::theme(plot.title = title_element, ...)
}
local_title_device <- function(width = 5, height = 3, env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".png", .local_envir = env)
  ragg::agg_png(path, width = width, height = height, units = "in", res = 96)
  withr::defer(grDevices::dev.off(), envir = env)
  grid::grid.newpage()
}

# Draws a table, then compares the height of the row of the title with the height
# of the text, for the width of the title in the cell where it is drawn.
expect_title_fits <- function(table, name = "title", fits = TRUE) {
  grid::grid.draw(table)
  index <- which(table$layout$name == name)
  cell <- paste0(
    name, ".",
    paste(
      table$layout$t[index], table$layout$r[index],
      table$layout$b[index], table$layout$l[index],
      sep = "-"
    )
  )
  depth <- grid::downViewport(cell)
  withr::defer(grid::upViewport(depth))

  title <- table$grobs[[index]]
  margin <- title$margin
  reserved <- grid::convertHeight(grid::unit(1, "npc"), "in", valueOnly = TRUE)
  inches <- function(u) grid::convertWidth(u, "in", valueOnly = TRUE)
  text <- title$children[[1]]
  text$max_width <- title$wrap_width %||%
    (inches(grid::unit(1, "npc")) - inches(margin[4]) - inches(margin[2]))
  needed <- dim(text)$height +
    grid::convertHeight(margin[1] + margin[3], "in", valueOnly = TRUE)

  if (fits) {
    expect_equal(reserved, needed, tolerance = 1e-3)
  } else {
    expect_lt(reserved, needed)
  }
}

test_that("the height of a title follows the width of its column", {
  skip_if_not_installed("ragg")
  local_title_device()

  expect_title_fits(ggplot2::ggplotGrob(title_plot()))
  expect_title_fits(
    ggplot2::ggplotGrob(title_plot(plot.title.position = "plot"))
  )
  expect_title_fits(
    ggplot2::ggplotGrob(title_plot() + ggplot2::facet_wrap(ggplot2::vars(x > 2)))
  )
})

test_that("subtitles, captions and element_chunks() are handled", {
  skip_if_not_installed("ragg")
  local_title_device()

  table <- ggplot2::ggplotGrob(
    title_plot(plot.subtitle = element_md()) +
      ggplot2::labs(subtitle = long_title)
  )
  expect_title_fits(table, "subtitle")

  table <- ggplot2::ggplotGrob(
    title_plot(plot.caption = element_md()) +
      ggplot2::labs(caption = strrep("long words ", 20))
  )
  expect_title_fits(table, "caption")

  chunks <- flextable::as_paragraph(flextable::as_chunk(strrep("long words ", 15)))
  expect_title_fits(ggplot2::ggplotGrob(title_plot(element_chunks(chunks))))
})

test_that("a title out of a gtable uses the width of its viewport", {
  skip_if_not_installed("ragg")
  local_title_device()

  grob <- ggplot2::element_grob(
    element_md(),
    label = long_title,
    margin = ggplot2::margin(),
    margin_x = TRUE
  )
  narrow <- grid::viewport(width = grid::unit(1, "in"))
  wide <- grid::viewport(width = grid::unit(4, "in"))
  height_in <- function(vp) {
    grid::pushViewport(vp)
    withr::defer(grid::popViewport())
    grid::convertHeight(grid::grobHeight(grob), "in", valueOnly = TRUE)
  }

  expect_gt(height_in(narrow), height_in(wide))
})

test_that("width sets the height of a title and how it wraps", {
  skip_if_not_installed("ragg")
  local_title_device()

  table <- ggplot2::ggplotGrob(title_plot(element_md(width = 2)))
  expect_title_fits(table)

  # the same text, for the same width
  title <- table$grobs[[which(table$layout$name == "title")]]
  drawn <- grid::makeContent(title)$children[[1]]
  expect_identical(drawn$max_width, 2)
  expect_equal(
    grid::convertHeight(grid::grobHeight(title), "in", valueOnly = TRUE),
    dim(drawn)$height +
      grid::convertHeight(
        title$margin[1] + title$margin[3],
        "in",
        valueOnly = TRUE
      )
  )

  chunks <- flextable::as_paragraph(flextable::as_chunk(strrep("long words ", 15)))
  table <- ggplot2::ggplotGrob(title_plot(element_chunks(chunks, width = 2)))
  expect_title_fits(table)
})

test_that("width solves the height of titles with patchwork", {
  skip_if_not_installed("ragg")
  skip_if_not_installed("patchwork")
  local_title_device()
  columns <- function(element) {
    patchwork::patchworkGrob(
      patchwork::wrap_plots(title_plot(element), title_plot(element))
    )
  }

  expect_title_fits(columns(element_md()), "title-1", fits = FALSE)
  expect_title_fits(columns(element_md(width = 1.2)), "title-1")
})

test_that("width solves the height of titles with a fixed aspect ratio", {
  skip_if_not_installed("ragg")
  local_title_device()

  fixed <- ggplot2::ggplotGrob(
    title_plot(element_md(width = 2)) + ggplot2::coord_fixed()
  )
  expect_title_fits(fixed)
})

test_that("width is ignored for rotated text", {
  skip_if_not_installed("ragg")
  local_title_device()
  grob <- ggplot2::element_grob(
    element_md(angle = 90, width = 0.5),
    label = long_title,
    margin = ggplot2::margin(),
    margin_x = TRUE
  )

  expect_false(grob$auto_wrap)
})

test_that("width is checked and kept when elements are merged", {
  expect_error(element_md(width = "a"), "positive number")
  expect_error(element_md(width = 0), "positive number")
  expect_error(element_md(width = c(1, 2)), "positive number")
  chunks <- flextable::as_paragraph(flextable::as_chunk("a"))
  expect_error(element_chunks(chunks, width = -1), "positive number")

  expect_identical(
    ggplot2::merge_element(element_md(), element_md(width = 2))$width,
    2
  )
  expect_identical(
    ggplot2::merge_element(
      element_chunks(chunks),
      element_chunks(chunks, width = 2)
    )$width,
    2
  )
  expect_null(ggplot2::merge_element(element_md(), ggplot2::element_text())$width)
})
