library(flextable)
library(ggplot2)
library(patchwork)

caption_chunks <- as_paragraph(as_chunk("A caption with "), as_b("bold"))
title_chunks <- as_paragraph(as_chunk("A title"))

p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
patch <- wrap_plots(p, p)

# --- constructor ---

test_that("munch_annotation returns correct class", {
  ann <- munch_annotation()
  expect_s3_class(ann, "munch_annotation")
  expect_s3_class(ann, "gg")
})

test_that("munch_annotation accepts NULL for all text args", {
  ann <- munch_annotation(caption = NULL, title = NULL, subtitle = NULL)
  expect_null(ann$caption)
  expect_null(ann$title)
  expect_null(ann$subtitle)
})

test_that("munch_annotation accepts paragraph objects", {
  ann <- munch_annotation(caption = caption_chunks, title = title_chunks)
  expect_s3_class(ann$caption, "paragraph")
  expect_s3_class(ann$title, "paragraph")
})

test_that("munch_annotation accepts element_chunks objects", {
  el <- element_chunks(caption_chunks, hjust = 0, lineheight = 1.5)
  ann <- munch_annotation(caption = el)
  expect_s3_class(ann$caption, "element_chunks")
})

test_that("munch_annotation accepts element_md objects", {
  el <- element_md(size = 10)
  ann <- munch_annotation(caption = el)
  expect_s3_class(ann$caption, "element_md")
})

test_that("munch_annotation accepts plain character strings", {
  ann <- munch_annotation(caption = "plain", title = "title")
  expect_equal(ann$caption, "plain")
  expect_equal(ann$title, "title")
})

test_that("munch_annotation rejects invalid caption type", {
  expect_snapshot(
    munch_annotation(caption = 123),
    error = TRUE
  )
})

test_that("munch_annotation rejects invalid title type", {
  expect_snapshot(
    munch_annotation(title = list(a = 1)),
    error = TRUE
  )
})

# --- ggplot_add: sentinel wiring ---

test_that("ggplot_add sets sentinel caption for paragraph input", {
  result <- patch + munch_annotation(caption = caption_chunks)
  expect_equal(result$patches$annotation$caption, " ")
})

test_that("ggplot_add sets sentinel caption for element_chunks input", {
  result <- patch +
    munch_annotation(
      caption = element_chunks(caption_chunks, hjust = 0)
    )
  expect_equal(result$patches$annotation$caption, " ")
})

test_that("ggplot_add sets sentinel title for paragraph input", {
  result <- patch + munch_annotation(title = title_chunks)
  expect_equal(result$patches$annotation$title, " ")
})

test_that("ggplot_add passes plain string caption unchanged", {
  result <- patch + munch_annotation(caption = "plain caption")
  expect_equal(result$patches$annotation$caption, "plain caption")
})

test_that("ggplot_add leaves caption NULL when not provided", {
  result <- patch + munch_annotation(title = "title only")
  expect_null(result$patches$annotation$caption)
})

# --- ggplot_add: theme elements ---

test_that("ggplot_add sets element_chunks in plot.caption theme", {
  result <- patch + munch_annotation(caption = caption_chunks)
  caption_el <- result$patches$annotation$theme$plot.caption
  expect_s3_class(caption_el, "element_chunks")
})

test_that("ggplot_add preserves element_chunks passed directly", {
  el <- element_chunks(caption_chunks, hjust = 0, lineheight = 1.5)
  result <- patch + munch_annotation(caption = el)
  caption_el <- result$patches$annotation$theme$plot.caption
  expect_s3_class(caption_el, "element_chunks")
  expect_equal(caption_el$hjust, 0)
  expect_equal(caption_el$lineheight, 1.5)
})

test_that("ggplot_add merges user theme on top of munch theme", {
  result <- patch +
    munch_annotation(
      caption = caption_chunks,
      theme = theme(plot.background = element_rect(fill = "grey90"))
    )
  bg <- result$patches$annotation$theme$plot.background
  expect_s3_class(bg, "element_rect")
})

test_that("ggplot_add sets no theme element for plain string caption", {
  result <- patch + munch_annotation(caption = "plain")
  # theme should be NULL or not contain a plot.caption element_chunks
  theme_el <- result$patches$annotation$theme$plot.caption
  expect_false(inherits(theme_el, "element_chunks"))
})
