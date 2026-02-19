# Tests requiring a compatible graphics device (ragg::agg_png)
# These cover element_grob, makeContent, widthDetails, heightDetails,
# plot.mdGrob, and check_device_compatibility branches.

# helper: open ragg device, run code, close device
with_ragg <- function(code, width = 6, height = 4) {
  testthat::skip_if_not_installed("ragg")
  gdtools::font_set_liberation()
  path <- tempfile(fileext = ".png")
  ragg::agg_png(path, width = width, height = height, units = "in", res = 72)
  on.exit({
    dev.off()
    unlink(path)
  })
  force(code)
}

# --- check_device_compatibility ---

test_that("check_device_compatibility passes with ragg", {
  with_ragg({
    expect_invisible(munch:::check_device_compatibility())
  })
})

# --- makeContent.mdGrob ---

test_that("makeContent.mdGrob renders text", {
  with_ragg({
    gr <- md_grob("Hello **world**")
    result <- grid::makeContent(gr)

    expect_s3_class(result, "mdGrob")
    # Should have text grobs as children
    expect_gt(length(result$children), 0)
  })
})

test_that("makeContent.mdGrob renders empty grob", {
  with_ragg({
    gr <- md_grob("test")
    gr$chunks <- gr$chunks[0, ]
    result <- grid::makeContent(gr)

    expect_s3_class(result, "mdGrob")
  })
})

test_that("makeContent.mdGrob renders multiline text", {
  with_ragg({
    gr <- md_grob("line1\n\nline2")
    result <- grid::makeContent(gr)

    expect_gt(length(result$children), 0)
  })
})

test_that("makeContent.mdGrob renders with wrapping", {
  with_ragg({
    gr <- md_grob("word1 word2 word3 word4 word5", width = 0.5)
    result <- grid::makeContent(gr)

    expect_gt(length(result$children), 0)
  })
})

test_that("makeContent.mdGrob renders spaces correctly", {
  with_ragg({
    gr <- md_grob("hello world")
    result <- grid::makeContent(gr)

    # "hello" and "world" as textGrobs, space handled by positioning
    child_names <- vapply(
      seq_along(result$children),
      function(i) result$children[[i]]$name,
      character(1)
    )
    expect_true(any(grepl("chunk_", child_names)))
  })
})

test_that("makeContent.mdGrob renders highlight rect", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_highlight(
        flextable::as_chunk("highlighted"),
        color = "yellow"
      )
    )
    gr <- chunks_grob(chunks)
    result <- grid::makeContent(gr)

    child_names <- vapply(
      seq_along(result$children),
      function(i) result$children[[i]]$name,
      character(1)
    )
    expect_true(any(grepl("highlight_", child_names)))
  })
})

test_that("makeContent.mdGrob renders strikethrough", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_strike(flextable::as_chunk("deleted"))
    )
    gr <- chunks_grob(chunks)
    result <- grid::makeContent(gr)

    child_names <- vapply(
      seq_along(result$children),
      function(i) result$children[[i]]$name,
      character(1)
    )
    expect_true(any(grepl("strike_", child_names)))
  })
})

# --- plot.mdGrob ---

test_that("plot.mdGrob draws without error", {
  with_ragg({
    gr <- md_grob("Hello **world**")

    expect_no_error(plot(gr))
    expect_invisible(plot(gr))
  })
})

# --- element_grob.element_md ---

test_that("element_grob.element_md creates mdTitleGrob", {
  with_ragg({
    el <- element_md(size = 12, colour = "black")
    result <- ggplot2::element_grob(
      el,
      label = "**Bold title**"
    )

    expect_s3_class(result, "mdTitleGrob")
    expect_s3_class(result, "gTree")
  })
})

test_that("element_grob.element_md returns zeroGrob for empty label", {
  with_ragg({
    el <- element_md()
    result <- ggplot2::element_grob(el, label = "")

    expect_s3_class(result, "zeroGrob")
  })
})

test_that("element_grob.element_md returns zeroGrob for NULL label", {
  with_ragg({
    el <- element_md()
    result <- ggplot2::element_grob(el, label = NULL)

    expect_s3_class(result, "zeroGrob")
  })
})

test_that("element_grob.element_md with rotation", {
  with_ragg({
    el <- element_md(size = 12)
    result <- ggplot2::element_grob(
      el,
      label = "Rotated",
      angle = 90
    )

    expect_s3_class(result, "mdTitleGrob")
  })
})

test_that("element_grob.element_md with margins", {
  with_ragg({
    el <- element_md(
      size = 12,
      margin = ggplot2::margin(5, 5, 5, 5)
    )
    result <- ggplot2::element_grob(
      el,
      label = "With margins",
      margin_x = TRUE,
      margin_y = TRUE
    )

    expect_s3_class(result, "mdTitleGrob")
    expect_true(result$auto_wrap)
  })
})

test_that("element_grob.element_md with margin_x no auto_wrap (rotated)", {
  with_ragg({
    el <- element_md(size = 12)
    result <- ggplot2::element_grob(
      el,
      label = "Rotated",
      angle = 90,
      margin_x = TRUE,
      margin_y = TRUE
    )

    expect_s3_class(result, "mdTitleGrob")
    expect_false(result$auto_wrap)
  })
})

test_that("element_grob.element_md with empty family falls back to sans", {
  with_ragg({
    el <- element_md(family = "")
    result <- ggplot2::element_grob(
      el,
      label = "Test"
    )

    expect_s3_class(result, "mdTitleGrob")
  })
})

test_that("element_grob.element_md resolves all parameters", {
  with_ragg({
    el <- element_md(
      size = 14,
      colour = "red",
      family = "Liberation Sans",
      code_font_family = "Liberation Mono",
      hjust = 0,
      vjust = 1,
      lineheight = 1.5
    )
    result <- ggplot2::element_grob(
      el,
      label = "**Bold** `code`"
    )

    expect_s3_class(result, "mdTitleGrob")
  })
})

# --- element_grob.element_chunks ---

test_that("element_grob.element_chunks creates chunksGrob", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("E = mc"),
      flextable::as_sup("2")
    )
    el <- element_chunks(chunks)
    result <- ggplot2::element_grob(el, label = "ignored")

    expect_s3_class(result, "chunksGrob")
    expect_s3_class(result, "gTree")
  })
})

test_that("element_grob.element_chunks returns zeroGrob for NULL chunks", {
  with_ragg({
    el <- structure(
      list(
        chunks = NULL,
        hjust = NULL, vjust = NULL, angle = NULL,
        lineheight = NULL, margin = NULL,
        debug = FALSE, inherit.blank = FALSE
      ),
      class = c("element_chunks", "element_text", "element")
    )
    result <- ggplot2::element_grob(el, label = "")

    expect_s3_class(result, "zeroGrob")
  })
})

test_that("element_grob.element_chunks with rotation", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Rotated")
    )
    el <- element_chunks(chunks, angle = 90)
    result <- ggplot2::element_grob(el, label = "")

    expect_s3_class(result, "chunksGrob")
    expect_false(result$auto_wrap)
  })
})

test_that("element_grob.element_chunks with margins", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("With margins")
    )
    el <- element_chunks(
      chunks,
      margin = ggplot2::margin(5, 5, 5, 5)
    )
    result <- ggplot2::element_grob(
      el,
      label = "",
      margin_x = TRUE,
      margin_y = TRUE
    )

    expect_s3_class(result, "chunksGrob")
    expect_true(result$auto_wrap)
  })
})

test_that("element_grob.element_chunks with chunk dataframe", {
  with_ragg({
    chunk_df <- flextable::as_paragraph(
      flextable::as_chunk("test")
    )[[1]]
    class(chunk_df) <- c("chunk", "data.frame")
    el <- element_chunks(chunk_df)
    result <- ggplot2::element_grob(el, label = "")

    expect_s3_class(result, "chunksGrob")
  })
})

# --- widthDetails / heightDetails for mdTitleGrob ---

test_that("widthDetails.mdTitleGrob no auto_wrap", {
  with_ragg({
    el <- element_md(size = 12)
    gr <- ggplot2::element_grob(el, label = "Hello")

    expect_false(gr$auto_wrap)
    w <- grid::widthDetails(gr)
    expect_s3_class(w, "unit")
  })
})

test_that("widthDetails.mdTitleGrob auto_wrap returns npc", {
  with_ragg({
    el <- element_md(
      size = 12,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "Hello",
      margin_x = TRUE,
      margin_y = TRUE
    )

    expect_true(gr$auto_wrap)
    w <- grid::widthDetails(gr)
    expect_s3_class(w, "unit")
  })
})

test_that("heightDetails.mdTitleGrob no auto_wrap", {
  with_ragg({
    el <- element_md(size = 12)
    gr <- ggplot2::element_grob(el, label = "Hello")

    h <- grid::heightDetails(gr)
    expect_s3_class(h, "unit")
  })
})

test_that("heightDetails.mdTitleGrob auto_wrap resolves height", {
  with_ragg({
    el <- element_md(
      size = 12,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "Hello world",
      margin_x = TRUE,
      margin_y = TRUE
    )

    # Inside a viewport, heightDetails can resolve npc
    grid::pushViewport(grid::viewport(width = grid::unit(4, "in")))
    h <- grid::heightDetails(gr)
    grid::popViewport()
    expect_s3_class(h, "unit")
  })
})

# --- widthDetails / heightDetails for chunksGrob ---

test_that("widthDetails.chunksGrob no auto_wrap", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello")
    )
    el <- element_chunks(chunks)
    gr <- ggplot2::element_grob(el, label = "")

    w <- grid::widthDetails(gr)
    expect_s3_class(w, "unit")
  })
})

test_that("heightDetails.chunksGrob no auto_wrap", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello")
    )
    el <- element_chunks(chunks)
    gr <- ggplot2::element_grob(el, label = "")

    h <- grid::heightDetails(gr)
    expect_s3_class(h, "unit")
  })
})

test_that("widthDetails.chunksGrob auto_wrap returns npc", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello")
    )
    el <- element_chunks(
      chunks,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "",
      margin_x = TRUE,
      margin_y = TRUE
    )

    expect_true(gr$auto_wrap)
    w <- grid::widthDetails(gr)
    expect_s3_class(w, "unit")
  })
})

test_that("heightDetails.chunksGrob auto_wrap resolves height", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello world")
    )
    el <- element_chunks(
      chunks,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "",
      margin_x = TRUE,
      margin_y = TRUE
    )

    grid::pushViewport(grid::viewport(width = grid::unit(4, "in")))
    h <- grid::heightDetails(gr)
    grid::popViewport()
    expect_s3_class(h, "unit")
  })
})

# --- makeContent.mdTitleGrob ---

test_that("makeContent.mdTitleGrob no auto_wrap returns unchanged", {
  with_ragg({
    el <- element_md(size = 12)
    gr <- ggplot2::element_grob(el, label = "Hello")

    result <- grid::makeContent(gr)
    expect_s3_class(result, "mdTitleGrob")
  })
})

test_that("makeContent.mdTitleGrob auto_wrap rewraps", {
  with_ragg({
    el <- element_md(
      size = 12,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "Hello world long text",
      margin_x = TRUE,
      margin_y = TRUE
    )

    grid::pushViewport(grid::viewport(width = grid::unit(4, "in")))
    result <- grid::makeContent(gr)
    grid::popViewport()
    expect_s3_class(result, "mdTitleGrob")
  })
})

# --- makeContent.chunksGrob ---

test_that("makeContent.chunksGrob no auto_wrap returns unchanged", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello")
    )
    el <- element_chunks(chunks)
    gr <- ggplot2::element_grob(el, label = "")

    result <- grid::makeContent(gr)
    expect_s3_class(result, "chunksGrob")
  })
})

test_that("makeContent.chunksGrob auto_wrap rewraps", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("Hello world long text")
    )
    el <- element_chunks(
      chunks,
      margin = ggplot2::margin(2, 2, 2, 2)
    )
    gr <- ggplot2::element_grob(
      el,
      label = "",
      margin_x = TRUE,
      margin_y = TRUE
    )

    grid::pushViewport(grid::viewport(width = grid::unit(4, "in")))
    result <- grid::makeContent(gr)
    grid::popViewport()
    expect_s3_class(result, "chunksGrob")
  })
})

# --- full ggplot rendering through ragg ---

test_that("element_md renders in ggplot with ragg", {
  with_ragg({
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point() +
      ggplot2::labs(title = "**Bold** and *italic*") +
      ggplot2::theme(plot.title = element_md())

    expect_no_error(print(p))
  })
})

test_that("element_chunks renders in ggplot with ragg", {
  with_ragg({
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("R"),
      flextable::as_sup("2"),
      flextable::as_chunk(" = 0.95")
    )
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point() +
      ggplot2::theme(plot.caption = element_chunks(chunks))

    expect_no_error(print(p))
  })
})

test_that("element_md with rotation renders in ggplot with ragg", {
  with_ragg({
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point() +
      ggplot2::labs(y = "**Weight** (tons)") +
      ggplot2::theme(axis.title.y = element_md(angle = 90))

    expect_no_error(print(p))
  })
})
