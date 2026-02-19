test_that("flextable chunk_dataframe creates proper structure", {
  chunks <- flextable::chunk_dataframe(txt = "Hello")

  expect_s3_class(chunks, "chunk")
  expect_s3_class(chunks, "data.frame")
  expect_equal(nrow(chunks), 1)
  expect_equal(chunks$txt, "Hello")
})

test_that("flextable chunk_dataframe recycles values", {
  chunks <- flextable::chunk_dataframe(
    txt = c("a", "b", "c"),
    bold = TRUE
  )

  expect_equal(nrow(chunks), 3)
  expect_equal(chunks$bold, c(TRUE, TRUE, TRUE))
})

test_that("get_flextable_defaults returns expected defaults", {
  defaults <- flextable::get_flextable_defaults()

  expect_type(defaults, "list")
  expect_true(!is.null(defaults$font.size))
  expect_true(!is.null(defaults$font.family))
  expect_true(!is.null(defaults$font.color))
})

test_that("flextable as_paragraph combines chunks", {
  para <- flextable::as_paragraph(
    flextable::as_chunk("Hello "),
    flextable::as_b("world")
  )

  expect_s3_class(para, "paragraph")
  # paragraph is a list of data.frames
  expect_equal(length(para), 1)
  chunk_df <- para[[1]]
  expect_equal(nrow(chunk_df), 2)
  expect_equal(chunk_df$txt, c("Hello ", "world"))
  expect_equal(chunk_df$bold, c(NA, TRUE))
})

# --- apply_defaults ---

test_that("apply_defaults fills NA values", {
  chunks <- flextable::chunk_dataframe(txt = "test")
  result <- munch:::apply_defaults(chunks)

  expect_false(is.na(result$font.size))
  expect_false(is.na(result$font.family))
  expect_false(is.na(result$color))
  expect_false(is.na(result$bold))
  expect_false(is.na(result$italic))
  expect_false(is.na(result$underlined))
  expect_false(is.na(result$shading.color))
  expect_false(is.na(result$vertical.align))
})

test_that("apply_defaults with NULL text_props uses defaults", {
  chunks <- flextable::chunk_dataframe(txt = "test")
  result <- munch:::apply_defaults(chunks, text_props = NULL)

  ft <- flextable::get_flextable_defaults()
  expect_equal(result$font.size, ft$font.size)
  expect_equal(result$font.family, ft$font.family)
})

test_that("apply_defaults with custom text_props", {
  chunks <- flextable::chunk_dataframe(txt = "test")
  props <- default_text_props(
    font_size = 20,
    font_family = "Liberation Sans",
    font_color = "red"
  )
  result <- munch:::apply_defaults(chunks, text_props = props)

  expect_equal(result$font.size, 20)
  expect_equal(result$font.family, "Liberation Sans")
  expect_equal(result$color, "red")
})

test_that("apply_defaults preserves non-NA values", {
  chunks <- flextable::chunk_dataframe(
    txt = "test",
    bold = TRUE,
    italic = TRUE,
    font.size = 14
  )
  result <- munch:::apply_defaults(chunks)

  expect_true(result$bold)
  expect_true(result$italic)
  expect_equal(result$font.size, 14)
})

# --- split_chunks_into_words ---

test_that("split_chunks_into_words handles empty chunks", {
  chunks <- flextable::chunk_dataframe(txt = "a")[0, ]
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 0)
})

test_that("split_chunks_into_words splits multi-word text", {
  chunks <- flextable::chunk_dataframe(txt = "foo bar baz")
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 5)
  expect_equal(result$txt, c("foo", " ", "bar", " ", "baz"))
  expect_s3_class(result, "chunk")
})

test_that("split_chunks_into_words keeps single word", {
  chunks <- flextable::chunk_dataframe(txt = "hello")
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
  expect_equal(result$txt, "hello")
})

test_that("split_chunks_into_words skips newline chunks", {
  chunks <- flextable::chunk_dataframe(txt = "\n")
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
  expect_equal(result$txt, "\n")
})

test_that("split_chunks_into_words skips paragraph break chunks", {
  chunks <- flextable::chunk_dataframe(txt = "\n\n")
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
  expect_equal(result$txt, "\n\n")
})

test_that("split_chunks_into_words skips space chunks", {
  chunks <- flextable::chunk_dataframe(txt = " ")
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
  expect_equal(result$txt, " ")
})

test_that("split_chunks_into_words skips NA txt (image)", {
  chunks <- flextable::chunk_dataframe(txt = NA_character_)
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
  expect_true(is.na(result$txt))
})

test_that("split_chunks_into_words skips img_path chunks", {
  chunks <- flextable::chunk_dataframe(txt = NA_character_)
  chunks$img_path <- "/some/image.png"
  chunks <- munch:::apply_defaults(chunks)
  result <- munch:::split_chunks_into_words(chunks)

  expect_equal(nrow(result), 1)
})

# --- rbind_chunks ---

test_that("rbind_chunks combines two chunk dataframes", {
  c1 <- flextable::chunk_dataframe(txt = "a")
  c2 <- flextable::chunk_dataframe(txt = "b")
  result <- munch:::rbind_chunks(c1, c2)

  expect_equal(nrow(result), 2)
  expect_equal(result$txt, c("a", "b"))
  expect_s3_class(result, "chunk")
})

test_that("rbind_chunks handles all NULL inputs", {
  result <- munch:::rbind_chunks(NULL, NULL)

  expect_s3_class(result, "chunk")
  expect_equal(nrow(result), 0)
})

test_that("rbind_chunks fills missing columns with NA", {
  c1 <- flextable::chunk_dataframe(txt = "a", bold = TRUE)
  c2 <- flextable::chunk_dataframe(txt = "b")
  result <- munch:::rbind_chunks(c1, c2)

  expect_true("bold" %in% names(result))
  expect_equal(nrow(result), 2)
})

test_that("rbind_chunks skips NULL entries", {
  c1 <- flextable::chunk_dataframe(txt = "a")
  result <- munch:::rbind_chunks(c1, NULL, NULL)

  expect_equal(nrow(result), 1)
  expect_equal(result$txt, "a")
})
