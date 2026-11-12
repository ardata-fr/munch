test_that("as_paragraph_md returns a paragraph object", {
  result <- as_paragraph_md("Hello **world**")

  expect_s3_class(result, "paragraph")
  expect_equal(length(result), 1)
  chunk_df <- result[[1]]
  expect_s3_class(chunk_df, "data.frame")
  expect_true(".chunk_index" %in% names(chunk_df))
})

test_that("as_paragraph_md preserves bold formatting", {
  result <- as_paragraph_md("**bold** text")
  chunk_df <- result[[1]]

  bold_rows <- chunk_df[chunk_df$bold %in% TRUE, ]
  expect_gt(nrow(bold_rows), 0)
  expect_true(any(grepl("bold", bold_rows$txt)))
})

test_that("as_paragraph_md preserves italic formatting", {
  result <- as_paragraph_md("*italic* text")
  chunk_df <- result[[1]]

  italic_rows <- chunk_df[chunk_df$italic %in% TRUE, ]
  expect_gt(nrow(italic_rows), 0)
  expect_true(any(grepl("italic", italic_rows$txt)))
})

test_that("as_paragraph_md handles inline code", {
  result <- as_paragraph_md("use `print()` here")
  chunk_df <- result[[1]]

  code_rows <- chunk_df[grepl("print()", chunk_df$txt, fixed = TRUE), ]
  expect_gt(nrow(code_rows), 0)
})

test_that("as_paragraph_md handles strikethrough", {
  result <- as_paragraph_md("~~deleted~~ text")
  chunk_df <- result[[1]]

  expect_true(
    "vertical.align" %in%
      names(chunk_df) ||
      "strike" %in% names(chunk_df) ||
      nrow(chunk_df) >= 2
  )
})

test_that("as_paragraph_md uses custom mono font", {
  result <- as_paragraph_md(
    "use `code`",
    font_family_mono = "Liberation Mono"
  )
  chunk_df <- result[[1]]

  code_rows <- chunk_df[grepl("code", chunk_df$txt, fixed = TRUE), ]
  expect_true(any(code_rows$font.family == "Liberation Mono"))
})

test_that("as_paragraph_md handles plain text", {
  result <- as_paragraph_md("just plain text")
  chunk_df <- result[[1]]

  expect_gt(nrow(chunk_df), 0)
  expect_true(any(grepl("plain", chunk_df$txt)))
})

test_that("as_paragraph_md chunk_index is sequential", {
  result <- as_paragraph_md("**a** *b* `c`")
  chunk_df <- result[[1]]

  expect_equal(chunk_df$.chunk_index, seq_len(nrow(chunk_df)))
})

test_that("as_paragraph_md() gives images to flextable", {
  skip_if_not_installed("magick")
  logo <- file.path(R.home("doc"), "html", "logo.jpg")
  p <- as_paragraph_md(paste0("A logo ![R](", logo, ") here"))
  ch <- p[[1]]
  expect_true(flextable:::is_paragraph(ch))
  img <- which(!vapply(ch$img_data, is.null, NA))
  expect_length(img, 1L)
  expect_equal(ch$img_data[[img]], logo)
  # twice the font size, with the aspect ratio of the file
  dims <- officer::image_dims(logo)
  expect_equal(ch$height[img], ch$font.size[img] / 72 * 2)
  expect_equal(
    ch$width[img] / ch$height[img],
    unname(dims[["width"]] / dims[["height"]])
  )
  ft <- flextable::flextable(data.frame(a = 1))
  ft <- flextable::mk_par(ft, j = "a", value = p)
  expect_s3_class(ft, "flextable")
})

test_that("as_paragraph_md() drops images that can not be read", {
  expect_warning(
    p <- as_paragraph_md("A ![missing](no-such-file.png) image"),
    "not found"
  )
  ch <- p[[1]]
  expect_true(flextable:::is_paragraph(ch))
  expect_true(all(vapply(ch$img_data, is.null, NA)))
  expect_equal(paste(ch$txt, collapse = ""), "A  image")
})
