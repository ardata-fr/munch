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

with_cairo_pdf <- function(code) {
  # capabilities("cairo") is fixed when R is built; grSoftVersion() loads
  # the cairo module of R, which fails on macOS without XQuartz
  cairo_loads <- suppressWarnings(nzchar(grDevices::grSoftVersion()[["cairo"]]))
  testthat::skip_if_not(cairo_loads, "the cairo module of R can not be loaded")
  path <- tempfile(fileext = ".pdf")
  grDevices::cairo_pdf(path)
  on.exit({
    dev.off()
    unlink(path)
  })
  force(code)
}

test_that("cairo_pdf() is accepted when R draws its text with Pango", {
  local_mocked_bindings(cairo_has_pango = function() TRUE)
  with_cairo_pdf({
    expect_no_warning(munch:::check_device_compatibility())
  })
})

test_that("cairo_pdf() without Pango warns that it does not kern", {
  local_mocked_bindings(cairo_has_pango = function() FALSE)
  withr::local_options(rlib_warning_verbosity = "verbose")
  with_cairo_pdf({
    expect_warning(munch:::check_device_compatibility(), "does not kern")
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
        hjust = NULL,
        vjust = NULL,
        angle = NULL,
        lineheight = NULL,
        margin = NULL,
        debug = FALSE,
        inherit.blank = FALSE
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

test_that("widthDetails.mdTitleGrob auto_wrap returns natural content width in inches", {
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
    # Must be absolute inches so legend columns are sized correctly,
    # not unit(1, "npc") which would collapse the plot panel.
    expect_equal(grid::unitType(w), "inches")
    expect_gt(grid::convertWidth(w, "inches", valueOnly = TRUE), 0)
  })
})

test_that("the width of a title includes its left and right margins", {
  # legends size the column of their labels with this width; without the
  # margins, the widest label wrapped and overflowed on the next key
  with_ragg({
    margin <- ggplot2::margin(0, 10, 0, 20, unit = "pt")
    titles <- list(
      ggplot2::element_grob(
        element_md(size = 12, margin = margin),
        label = "A legend label",
        margin_x = TRUE,
        margin_y = TRUE
      ),
      ggplot2::element_grob(
        element_chunks(
          flextable::as_paragraph(flextable::as_chunk("A legend label")),
          margin = margin
        ),
        label = "",
        margin_x = TRUE,
        margin_y = TRUE
      )
    )
    for (gr in titles) {
      w <- grid::convertWidth(grid::widthDetails(gr), "pt", valueOnly = TRUE)
      content_w <- grid::convertWidth(gr$content_w, "pt", valueOnly = TRUE)
      expect_equal(w - content_w, 30, tolerance = 1e-6)
    }
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

test_that("widthDetails.chunksGrob auto_wrap returns natural content width in inches", {
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
    expect_equal(grid::unitType(w), "inches")
    expect_gt(grid::convertWidth(w, "inches", valueOnly = TRUE), 0)
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

test_that("element_chunks() takes the format of the chunks, then of the theme", {
  with_ragg({
    old <- flextable::set_flextable_defaults(
      font.size = 10,
      font.family = "Liberation Mono",
      font.color = "black"
    )
    withr::defer(do.call(flextable::set_flextable_defaults, old))
    chunks <- flextable::as_paragraph(
      flextable::as_chunk("a"),
      flextable::as_chunk(
        "b",
        props = officer::fp_text_lite(
          font.size = 40,
          font.family = "Liberation Sans",
          color = "green",
          bold = FALSE
        )
      )
    )
    title_chunks <- function(element, theme) {
      theme <- theme + ggplot2::theme(plot.title = element)
      el <- ggplot2::calc_element("plot.title", theme)
      ggplot2::element_grob(el, label = "")$children[[1]]$chunks
    }
    th <- ggplot2::theme_minimal(
      base_size = 20,
      base_family = "Liberation Serif"
    ) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(colour = "red", face = "bold")
      )

    # the theme fills what the chunk does not set
    ch <- title_chunks(element_chunks(chunks), th)
    expect_equal(ch$font.size, c(24, 40))
    expect_equal(ch$font.family, c("Liberation Serif", "Liberation Sans"))
    expect_equal(ch$color, c("red", "green"))
    expect_equal(ch$bold, c(TRUE, FALSE))

    # size of the element before the theme
    ch <- title_chunks(element_chunks(chunks, size = 30), th)
    expect_equal(ch$font.size, c(30, 40))

    # an empty family, the default of the themes, keeps the flextable default
    ch <- title_chunks(element_chunks(chunks), ggplot2::theme_minimal())
    expect_equal(ch$font.family, c("Liberation Mono", "Liberation Sans"))
  })
})

test_that("an empty font family of the theme gives the flextable font", {
  with_ragg({
    old <- flextable::set_flextable_defaults(font.family = "Liberation Mono")
    withr::defer(do.call(flextable::set_flextable_defaults, old))
    th <- ggplot2::theme_minimal()
    expect_identical(th$text$family, "")

    drawn_families <- function(x) {
      if (!is.null(x$chunks)) {
        return(unique(x$chunks$font.family))
      }
      unique(unlist(lapply(x$children, drawn_families)))
    }
    title_family <- function(element) {
      el <- ggplot2::calc_element(
        "plot.title",
        th + ggplot2::theme(plot.title = element)
      )
      drawn_families(ggplot2::element_grob(el, label = "a"))
    }
    expect_equal(title_family(element_md()), "Liberation Mono")
    expect_equal(
      title_family(element_chunks(flextable::as_paragraph("a"))),
      "Liberation Mono"
    )

    dat <- data.frame(x = 0, y = 0, label = "a")
    for (geom in list(geom_text_md(), geom_label_md())) {
      p <- ggplot2::ggplot(dat, ggplot2::aes(x, y, label = label)) + geom + th
      grob <- ggplot2::layer_grob(p)[[1]]
      expect_equal(drawn_families(grob), "Liberation Mono")
    }
  })
})
