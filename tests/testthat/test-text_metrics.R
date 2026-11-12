# helper: minimal text chunk data.frame
make_chunks <- function(
  txt = "hello",
  font.family = "Liberation Sans",
  font.size = 12,
  font.color = "black",
  bold = FALSE,
  italic = FALSE,
  vertical.align = "baseline",
  img_data = list(NULL),
  img_path = NA_character_,
  img_width = NA_real_,
  img_height = NA_real_
) {
  n <- length(txt)
  data.frame(
    txt = txt,
    font.family = rep(font.family, length.out = n),
    font.size = rep(font.size, length.out = n),
    font.color = rep(font.color, length.out = n),
    bold = rep(bold, length.out = n),
    italic = rep(italic, length.out = n),
    vertical.align = rep(vertical.align, length.out = n),
    img_data = I(rep(img_data, length.out = n)),
    img_path = rep(img_path, length.out = n),
    img_width = rep(img_width, length.out = n),
    img_height = rep(img_height, length.out = n),
    stringsAsFactors = FALSE
  )
}

# --- calc_chunk_metrics ---

test_that("calc_chunk_metrics returns expected columns", {
  chunks <- make_chunks("hello")
  result <- munch:::calc_chunk_metrics(chunks)

  expect_true("width" %in% names(result))
  expect_true("height" %in% names(result))
  expect_true("ascent" %in% names(result))
  expect_true("descent" %in% names(result))
  expect_true("is_newline" %in% names(result))
  expect_true("is_space" %in% names(result))
})

test_that("calc_chunk_metrics text width is positive", {
  chunks <- make_chunks("hello world")
  result <- munch:::calc_chunk_metrics(chunks)

  expect_gt(result$width[1], 0)
  expect_gt(result$height[1], 0)
  expect_gt(result$ascent[1], 0)
  expect_gt(result$descent[1], 0)
})

test_that("calc_chunk_metrics handles empty chunks", {
  chunks <- make_chunks()[0, ]
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(nrow(result), 0)
  expect_equal(length(result$width), 0)
  expect_equal(length(result$height), 0)
  expect_equal(length(result$ascent), 0)
  expect_equal(length(result$descent), 0)
  expect_equal(length(result$is_newline), 0)
  expect_equal(length(result$is_space), 0)
})

test_that("calc_chunk_metrics detects newlines", {
  chunks <- make_chunks(c("hello", "\n", "world"))
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$is_newline, c(FALSE, TRUE, FALSE))
})

test_that("calc_chunk_metrics detects spaces", {
  chunks <- make_chunks(c("hello", " ", "world"))
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$is_space, c(FALSE, TRUE, FALSE))
})

test_that("calc_chunk_metrics applies line_spacing", {
  chunks <- make_chunks("A")
  r1 <- munch:::calc_chunk_metrics(chunks, line_spacing = 1.0)
  r2 <- munch:::calc_chunk_metrics(chunks, line_spacing = 2.0)

  # as in Word, the added space is below the line
  expect_equal(r2$ascent[1], r1$ascent[1])
  expect_gt(r2$descent[1], r1$descent[1])
  expect_equal(r2$height[1], 2 * r1$height[1])
})

test_that("calc_chunk_metrics shrinks superscript", {
  chunks <- make_chunks(
    txt = c("E=mc", "2"),
    vertical.align = c("baseline", "superscript")
  )
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$font.size[2], 12 * 0.75)
})

test_that("calc_chunk_metrics shrinks subscript", {
  chunks <- make_chunks(
    txt = c("H", "2"),
    vertical.align = c("baseline", "subscript")
  )
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$font.size[2], 12 * 0.75)
})

test_that("calc_chunk_metrics handles missing img_path column", {
  chunks <- make_chunks("text")
  chunks$img_path <- NULL
  chunks$img_data <- NULL
  result <- munch:::calc_chunk_metrics(chunks)

  expect_gt(result$width[1], 0)
})

test_that("calc_chunk_metrics handles image chunk", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- make_chunks(
    txt = NA_character_,
    img_path = r_logo,
    img_width = 0.5,
    img_height = 0.4
  )
  result <- munch:::calc_chunk_metrics(chunks, img_baseline_ratio = 0.15)

  expect_equal(result$width[1], 0.5)
  expect_equal(result$height[1], 0.4)
  expect_equal(result$ascent[1], 0.4 * 0.85)
  expect_equal(result$descent[1], 0.4 * 0.15)
})

test_that("calc_chunk_metrics image with missing file", {
  chunks <- make_chunks(
    txt = NA_character_,
    img_path = "/nonexistent/image.png",
    img_width = 0.5,
    img_height = 0.4
  )
  result <- suppressWarnings(munch:::calc_chunk_metrics(chunks))

  expect_equal(result$width[1], 0)
  expect_equal(result$height[1], 0)
})

# --- calc_fontface ---

test_that("calc_fontface returns correct values", {
  expect_equal(munch:::calc_fontface(FALSE, FALSE), 1L)
  expect_equal(munch:::calc_fontface(TRUE, FALSE), 2L)
  expect_equal(munch:::calc_fontface(FALSE, TRUE), 3L)
  expect_equal(munch:::calc_fontface(TRUE, TRUE), 4L)
})

test_that("calc_fontface handles NA as FALSE", {
  expect_equal(munch:::calc_fontface(NA, NA), 1L)
  expect_equal(munch:::calc_fontface(NA, TRUE), 3L)
  expect_equal(munch:::calc_fontface(TRUE, NA), 2L)
})

# --- calc_chunk_metrics: img_data normalization ---

test_that("calc_chunk_metrics normalizes img_data to img_path", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- data.frame(
    txt = NA_character_,
    font.family = "Liberation Sans",
    font.size = 12,
    font.color = "black",
    bold = FALSE,
    italic = FALSE,
    vertical.align = "baseline",
    img_width = 0.5,
    img_height = 0.4,
    stringsAsFactors = FALSE
  )
  chunks$img_data <- I(list(r_logo))
  # No img_path column , should be created from img_data
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$img_path, r_logo)
  expect_equal(result$width[1], 0.5)
})

test_that("calc_chunk_metrics img_data fills NA img_path", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- data.frame(
    txt = NA_character_,
    font.family = "Liberation Sans",
    font.size = 12,
    font.color = "black",
    bold = FALSE,
    italic = FALSE,
    vertical.align = "baseline",
    img_path = NA_character_,
    img_width = 0.5,
    img_height = 0.4,
    stringsAsFactors = FALSE
  )
  chunks$img_data <- I(list(r_logo))
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$img_path, r_logo)
})

# --- calc_chunk_metrics: width/height consolidation ---

test_that("calc_chunk_metrics uses width column when img_width missing", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  # Simulate flextable::as_image style (width/height instead of img_width/img_height)
  chunks <- data.frame(
    txt = NA_character_,
    font.family = "Liberation Sans",
    font.size = 12,
    font.color = "black",
    bold = FALSE,
    italic = FALSE,
    vertical.align = "baseline",
    img_path = r_logo,
    width = 0.6,
    height = 0.5,
    stringsAsFactors = FALSE
  )
  chunks$img_data <- I(list(NULL))
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$width[1], 0.6)
  expect_equal(result$height[1], 0.5)
})

test_that("calc_chunk_metrics fills NA img_width from width column", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- data.frame(
    txt = NA_character_,
    font.family = "Liberation Sans",
    font.size = 12,
    font.color = "black",
    bold = FALSE,
    italic = FALSE,
    vertical.align = "baseline",
    img_path = r_logo,
    width = 0.7,
    height = 0.55,
    img_width = NA_real_,
    img_height = NA_real_,
    stringsAsFactors = FALSE
  )
  chunks$img_data <- I(list(NULL))
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$width[1], 0.7)
  expect_equal(result$height[1], 0.55)
})

# --- calc_chunk_metrics: image dimension inference ---

test_that("calc_chunk_metrics image with only height given", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- make_chunks(
    txt = NA_character_,
    img_path = r_logo,
    img_width = NA_real_,
    img_height = 0.5
  )
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$height[1], 0.5)
  # Width should be computed from aspect ratio
  expect_gt(result$width[1], 0)
})

test_that("calc_chunk_metrics image with only width given", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- make_chunks(
    txt = NA_character_,
    img_path = r_logo,
    img_width = 0.5,
    img_height = NA_real_
  )
  result <- munch:::calc_chunk_metrics(chunks)

  expect_equal(result$width[1], 0.5)
  # Height should be computed from aspect ratio
  expect_gt(result$height[1], 0)
})

test_that("calc_chunk_metrics image with neither width nor height", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  chunks <- make_chunks(
    txt = NA_character_,
    img_path = r_logo,
    img_width = NA_real_,
    img_height = NA_real_
  )
  result <- munch:::calc_chunk_metrics(chunks)

  # Default: 2x font size in inches
  expect_gt(result$width[1], 0)
  expect_gt(result$height[1], 0)
})

# --- calc_chunk_metrics: missing columns ---

test_that("calc_chunk_metrics handles no img_width column", {
  chunks <- data.frame(
    txt = "hello",
    font.family = "Liberation Sans",
    font.size = 12,
    font.color = "black",
    bold = FALSE,
    italic = FALSE,
    vertical.align = "baseline",
    stringsAsFactors = FALSE
  )
  result <- munch:::calc_chunk_metrics(chunks)

  expect_gt(result$width[1], 0)
  expect_equal(result$img_width[1], NA_real_)
  expect_equal(result$img_height[1], NA_real_)
})

test_that("words are measured with the kerning of the font, as ragg draws them", {
  skip_if_not_installed("ragg")
  props <- default_text_props(font_family = "Liberation Sans", font_size = 12)
  file <- tempfile(fileext = ".png")
  ragg::agg_png(file)
  on.exit({
    grDevices::dev.off()
    unlink(file)
  })
  grid::pushViewport(grid::viewport(
    gp = grid::gpar(fontfamily = "Liberation Sans", fontsize = 12)
  ))
  for (word in c("AVATAR", "Today,")) {
    drawn <- grid::convertWidth(grid::stringWidth(word), "bigpts", valueOnly = TRUE)
    measured <- grid::convertWidth(
      grid::grobWidth(md_grob(word, text_props = props)),
      "bigpts",
      valueOnly = TRUE
    )
    expect_equal(measured, drawn, tolerance = 0.05 / drawn)
  }
})
