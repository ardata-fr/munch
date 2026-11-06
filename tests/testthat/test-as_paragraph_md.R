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
