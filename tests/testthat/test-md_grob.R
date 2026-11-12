test_that("md_grob creates mdGrob object", {
  gr <- md_grob("Hello **world**")

  expect_s3_class(gr, "mdGrob")
  expect_s3_class(gr, "gTree")
})

test_that("md_grob stores chunks", {
  gr <- md_grob("**bold** text")

  expect_true("chunks" %in% names(gr))
  # After splitting into words, we have: "bold", " ", "text"
  expect_gte(nrow(gr$chunks), 2)
})

test_that("dim.mdGrob returns dimensions", {
  gr <- md_grob("Hello")
  dims <- dim(gr)

  expect_type(dims, "list")
  expect_true("width" %in% names(dims))
  expect_true("height" %in% names(dims))
  expect_gt(dims$width, 0)
  expect_gt(dims$height, 0)
})

test_that("chunks_grob creates mdGrob from flextable chunks", {
  chunks <- flextable::as_paragraph(
    flextable::as_chunk("E = mc"),
    flextable::as_sup("2")
  )
  gr <- chunks_grob(chunks)

  expect_s3_class(gr, "mdGrob")
  expect_gte(nrow(gr$chunks), 2)
})

test_that("md_grob handles empty text", {
  gr <- md_grob("")
  dims <- dim(gr)

  expect_s3_class(gr, "mdGrob")
})

# --- md_grob text_props ---

test_that("md_grob with custom text_props", {
  props <- default_text_props(
    font_size = 20,
    font_family = "Liberation Sans",
    line_spacing = 1.5
  )
  gr <- md_grob("Hello", text_props = props)

  expect_s3_class(gr, "mdGrob")
  expect_equal(gr$line_spacing, 1.5)
})

test_that("md_grob rejects invalid text_props", {
  expect_error(
    md_grob("Hello", text_props = list(a = 1)),
    "text_props"
  )
})

# --- md_grob with width (wrapping) ---

test_that("md_grob with max_width wraps text", {
  gr_nowrap <- md_grob("Hello world this is a long sentence")
  gr_wrap <- md_grob("Hello world this is a long sentence", width = 0.5)

  dims_nowrap <- dim(gr_nowrap)
  dims_wrap <- dim(gr_wrap)

  expect_s3_class(gr_wrap, "mdGrob")
  # Wrapped should be narrower than unwrapped
  expect_lt(dims_wrap$width, dims_nowrap$width)
  # Wrapped should be taller (more lines)
  expect_gt(dims_wrap$height, dims_nowrap$height)
})

test_that("the viewport has the wrapping width, where lines are aligned", {
  # lines are aligned within `width`: with a viewport as wide as the text,
  # hjust > 0 moved the text out of its anchor and out of label boxes
  for (hjust in c(0, 0.5, 1)) {
    gr <- md_grob("Hello", hjust = hjust, width = 2)
    expect_equal(grid::convertWidth(gr$vp$width, "inches", TRUE), 2)
    expect_lt(dim(gr)$width, 2)
  }
  # without width, the viewport is as wide as the text
  gr <- md_grob("Hello", hjust = 1)
  expect_equal(
    grid::convertWidth(gr$vp$width, "inches", TRUE),
    dim(gr)$width
  )
})

# --- dim.mdGrob empty ---

test_that("dim.mdGrob returns zero for empty grob", {
  gr <- md_grob("test")
  gr$chunks <- gr$chunks[0, ]
  dims <- dim(gr)

  expect_equal(dims$width, 0)
  expect_equal(dims$height, 0)
})

# --- print.mdGrob ---

test_that("print.mdGrob produces output", {
  gr <- md_grob("Hello **world**")
  output <- capture.output(print(gr))

  expect_true(any(grepl("mdGrob", output)))
  expect_true(any(grepl("Chunks", output)))
  expect_true(any(grepl("Dimensions", output)))
})

test_that("print.mdGrob returns invisibly", {
  gr <- md_grob("Hello")

  capture.output(expect_invisible(print(gr)))
  capture.output(result <- print(gr))
  expect_s3_class(result, "mdGrob")
})

test_that("print.mdGrob truncates long text", {
  long_text <- paste(rep("word", 30), collapse = " ")
  gr <- md_grob(long_text)
  output <- capture.output(print(gr))

  expect_true(any(grepl("\\.\\.\\.", output)))
})

# --- widthDetails / heightDetails ---

test_that("widthDetails.mdGrob returns unit", {
  gr <- md_grob("Hello")
  w <- grid::widthDetails(gr)

  expect_s3_class(w, "unit")
})

test_that("heightDetails.mdGrob returns unit", {
  gr <- md_grob("Hello")
  h <- grid::heightDetails(gr)

  expect_s3_class(h, "unit")
})

# --- arrange_chunks_into_lines ---

test_that("arrange_chunks_into_lines handles newlines", {
  chunks <- md_to_chunks("line1\n\nline2")
  chunks <- munch:::split_chunks_into_words(chunks)
  chunks <- munch:::calc_chunk_metrics(chunks)
  chunks$.chunk_index <- seq_len(nrow(chunks))

  lines <- munch:::arrange_chunks_into_lines(chunks)

  expect_gte(length(lines), 2)
})

test_that("arrange_chunks_into_lines wraps at max_width", {
  chunks <- md_to_chunks("word1 word2 word3 word4 word5")
  chunks <- munch:::split_chunks_into_words(chunks)
  chunks <- munch:::calc_chunk_metrics(chunks)
  chunks$.chunk_index <- seq_len(nrow(chunks))

  lines_unwrapped <- munch:::arrange_chunks_into_lines(chunks)
  lines_wrapped <- munch:::arrange_chunks_into_lines(chunks, max_width = 0.5)

  expect_gt(length(lines_wrapped), length(lines_unwrapped))
})

test_that("arrange_chunks_into_lines empty input", {
  chunks <- md_to_chunks("test")
  chunks <- chunks[0, ]

  lines <- munch:::arrange_chunks_into_lines(chunks)

  expect_length(lines, 1)
  expect_equal(lines[[1]]$width, 0)
  expect_gt(lines[[1]]$height, 0)
})

# --- chunks_grob ---

test_that("chunks_grob accepts paragraph object", {
  para <- flextable::as_paragraph(
    flextable::as_chunk("hello "),
    flextable::as_b("world")
  )
  gr <- chunks_grob(para)

  expect_s3_class(gr, "mdGrob")
})

test_that("chunks_grob accepts chunk data.frame", {
  chunk_df <- flextable::as_paragraph(
    flextable::as_chunk("test")
  )[[1]]
  gr <- chunks_grob(chunk_df)

  expect_s3_class(gr, "mdGrob")
})

# --- image_utils ---

test_that("get_image_info warns on NA path", {
  expect_warning(
    result <- munch:::get_image_info(NA_character_),
    "not found"
  )
  expect_null(result)
})

test_that("get_image_info warns on missing file", {
  expect_warning(
    result <- munch:::get_image_info("/nonexistent/file.png"),
    "not found"
  )
  expect_null(result)
})

test_that("get_image_info reads valid image", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  result <- munch:::get_image_info(r_logo)

  expect_type(result, "list")
  expect_true("width" %in% names(result))
  expect_true("height" %in% names(result))
  expect_gt(result$width, 0)
  expect_gt(result$height, 0)
})

test_that("get_image_info reads the dimensions from the file header", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  expect_equal(
    munch:::get_image_info(r_logo),
    list(width = 100, height = 76)
  )
})

test_that("get_image_info reads svg files with magick", {
  skip_if_not_installed("magick")
  svg <- file.path(R.home("doc"), "html", "Rlogo.svg")
  skip_if_not(file.exists(svg), "R svg logo not found")

  info <- magick::image_info(magick::image_read(svg))
  expect_equal(
    munch:::get_image_info(svg),
    list(width = info$width, height = info$height)
  )
})

test_that("read_image_raster returns NULL on NA path", {
  result <- munch:::read_image_raster(NA_character_)

  expect_null(result)
})

test_that("read_image_raster returns NULL on missing file", {
  result <- munch:::read_image_raster("/nonexistent/file.png")

  expect_null(result)
})

test_that("read_image_raster reads valid image", {
  skip_if_not_installed("magick")
  r_logo <- file.path(R.home("doc"), "html", "logo.jpg")
  skip_if_not(file.exists(r_logo), "R logo not found")

  result <- munch:::read_image_raster(r_logo)

  expect_s3_class(result, "nativeRaster")
})

test_that("read_image_raster warns on an unreadable file", {
  skip_if_not_installed("magick")
  bad <- withr::local_tempfile(fileext = ".png")
  writeLines("not an image", bad)

  expect_warning(result <- munch:::read_image_raster(bad), "Failed to read")
  expect_null(result)
})

test_that("an image is not decoded again when a grob is drawn again", {
  skip_if_not_installed("magick")
  path <- withr::local_tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(20, 10, "red"), path, format = "png")
  gr <- md_grob(paste0("a ![](", path, ") b"))

  # count the decodings of the file
  image_read <- magick::image_read
  n_read <- 0
  local_mocked_bindings(
    image_read = function(...) {
      n_read <<- n_read + 1
      image_read(...)
    },
    .package = "magick"
  )
  find_raster <- function(x) {
    Filter(function(z) inherits(z, "rastergrob"), grid::makeContent(x)$children)
  }
  first <- find_raster(gr)[[1]]$raster
  second <- find_raster(gr)[[1]]$raster

  expect_s3_class(first, "nativeRaster")
  expect_identical(second, first)
  expect_equal(n_read, 1)
})

test_that("an SVG image is rendered at the size it is drawn", {
  skip_if_not_installed("magick")
  skip_if_not_installed("rsvg")
  path <- withr::local_tempfile(fileext = ".svg")
  writeLines(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">',
      '<rect width="10" height="10" fill="red"/></svg>'
    ),
    path
  )
  raster <- munch:::read_image_raster(path, width = 1, height = 1)

  expect_equal(dim(raster), c(72L, 72L))
})

test_that("has_magick returns logical", {
  result <- munch:::has_magick()

  expect_type(result, "logical")
})

# --- check_device_compatibility ---

test_that("check_device_compatibility skips when option set", {
  skip_if_not_installed("withr")
  withr::with_options(list(munch.skip_device_check = TRUE), {
    expect_invisible(munch:::check_device_compatibility())
  })
})

test_that("lines follow the rules of flextable::layout_lines()", {
  make_chunks <- function(txt, width) {
    data.frame(
      txt = txt,
      width = width,
      height = 0.2,
      ascent = 0.15,
      descent = 0.05,
      max_ascend = 0.16,
      max_descend = 0.06,
      is_newline = txt == "\n",
      is_space = txt == " "
    )
  }
  line_text <- function(lines) {
    vapply(
      lines,
      function(line) paste(vapply(line$chunks, `[[`, "", "txt"), collapse = ""),
      character(1)
    )
  }

  chunks <- make_chunks(c("ab", " ", "cd"), c(1, .2, 1))
  expect_equal(line_text(arrange_chunks_into_lines(chunks, 3)), "ab cd")
  # the space that does not fit is dropped
  expect_equal(
    line_text(arrange_chunks_into_lines(chunks, 1.1)),
    c("ab", "cd")
  )

  # consecutive line breaks give an empty line, with a height
  chunks <- make_chunks(c("a", "\n", "\n", "b"), c(1, 0, 0, 1))
  lines <- arrange_chunks_into_lines(chunks, NULL)
  expect_equal(line_text(lines), c("a", "", "b"))
  expect_equal(lines[[2]]$height, 0.2)
  expect_equal(lines[[2]]$width, 0)

  # spaces written after a line break are kept
  chunks <- make_chunks(c("a", "\n", " ", "b"), c(1, 0, .2, 1))
  expect_equal(
    line_text(arrange_chunks_into_lines(chunks, NULL)),
    c("a", " b")
  )

  # no text
  lines <- arrange_chunks_into_lines(chunks[0, ], 3)
  expect_length(lines, 1L)
  expect_length(lines[[1]]$chunks, 0L)
})

# --- words wider than a line ---

word_lines <- function(text, width, ...) {
  chunks <- munch:::split_chunks_into_words(md_to_chunks(text, ...))
  chunks <- munch:::calc_chunk_metrics(chunks)
  chunks$.chunk_index <- seq_len(nrow(chunks))
  munch:::arrange_chunks_into_lines(chunks, width)
}
word_line_text <- function(lines) {
  vapply(
    lines,
    function(line) paste(vapply(line$chunks, `[[`, "", "txt"), collapse = ""),
    character(1)
  )
}

test_that("a word wider than a line is split, without hyphen", {
  word <- strrep("abcdefghij", 5)
  lines <- word_lines(word, 1)

  expect_gt(length(lines), 1L)
  expect_identical(paste(word_line_text(lines), collapse = ""), word)
  widths <- vapply(lines, `[[`, numeric(1), "width")
  expect_true(all(widths <= 1))
})

test_that("a word wider than a line starts on a new line", {
  word <- strrep("b", 50)
  lines <- word_line_text(word_lines(paste("a", word, "c"), 1))

  expect_identical(lines[1], "a ")
  expect_gt(nchar(lines[2]), 1L)
  expect_identical(paste(lines[-1], collapse = ""), paste(word, "c"))
})

test_that("a word wider than a line gives no empty line when it comes first", {
  word <- strrep("b", 50)

  expect_gt(nchar(word_line_text(word_lines(word, 1))[1]), 1L)
  lines <- word_line_text(word_lines(paste0("a  \n", word), 1))
  expect_identical(lines[1], "a")
  expect_gt(nchar(lines[2]), 1L)
})

test_that("a word that fits is not split", {
  lines <- word_lines("short words stay as they are", 1)

  texts <- unlist(strsplit(word_line_text(lines), " "))
  expect_setequal(texts, c("short", "words", "stay", "as", "they", "are"))
})

test_that("a word is not split without maximum width", {
  word <- strrep("a", 100)

  expect_identical(word_line_text(word_lines(word, NULL)), word)
})

test_that("a character is not split from its combining mark", {
  word <- strrep("e\u0301", 60)
  lines <- word_lines(word, 1)

  expect_gt(length(lines), 1L)
  expect_identical(paste(word_line_text(lines), collapse = ""), word)
  expect_true(all(startsWith(word_line_text(lines), "e\u0301")))
})

test_that("a character wider than a line stays on its own line", {
  expect_identical(
    word_line_text(word_lines("abc", 0.01)),
    c("a", "b", "c")
  )
})

test_that("a split word gives one text grob per line, with its properties", {
  word <- strrep("abcdefghij", 5)
  gr <- md_grob(paste0("**", word, "**"), width = 1)
  children <- grid::makeContent(gr)$children
  is_text <- vapply(children, inherits, logical(1), "text")
  labels <- vapply(children[is_text], function(z) z$label, character(1))

  expect_identical(paste(labels, collapse = ""), word)
  expect_identical(
    sum(is_text),
    length(word_lines(paste0("**", word, "**"), 1))
  )
  # all children are kept: their names are unique
  expect_equal(anyDuplicated(names(children)), 0L)
  faces <- vapply(children[is_text], function(z) z$gp$font, numeric(1))
  expect_true(all(faces == 2))
  expect_lte(dim(gr)$width, 1)
})

test_that("a superscript and an image are not split", {
  chunks <- flextable::as_paragraph(flextable::as_sup(strrep("a", 100)))[[1]]
  gr <- chunks_grob(chunks, width = 0.5)
  expect_gt(dim(gr)$width, 0.5)

  skip_if_not_installed("magick")
  path <- withr::local_tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(20, 10, "red"), path, format = "png")
  gr <- md_grob(paste0("![](", path, ")"), width = 0.01)
  children <- grid::makeContent(gr)$children
  expect_length(children, 1L)
  expect_s3_class(children[[1]], "rastergrob")
})

test_that("the split follows a width changed after the creation", {
  gr <- md_grob(strrep("a", 200), width = 4)
  height_large <- dim(gr)$height

  gr$max_width <- 1

  expect_gt(dim(gr)$height, height_large)
  expect_lte(dim(gr)$width, 1)
})
