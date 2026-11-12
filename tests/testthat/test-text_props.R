test_that("default_text_props returns text_props object", {
  props <- default_text_props()

  expect_s3_class(props, "text_props")
  expect_s3_class(props, "list")
})

test_that("default_text_props has all expected fields", {
  props <- default_text_props()

  expect_true("font.size" %in% names(props))
  expect_true("font.family" %in% names(props))
  expect_true("font.color" %in% names(props))
  expect_true("code.font.family" %in% names(props))
  expect_true("line_spacing" %in% names(props))
  expect_true("img_baseline_ratio" %in% names(props))
})

test_that("default_text_props inherits from flextable", {
  ft_defaults <- flextable::get_flextable_defaults()
  props <- default_text_props()

  expect_equal(props$font.size, ft_defaults$font.size)
  expect_equal(props$font.family, ft_defaults$font.family)
  expect_equal(props$font.color, ft_defaults$font.color)
})

test_that("default_text_props overrides work", {
  props <- default_text_props(
    font_size = 20,
    font_family = "Liberation Sans",
    font_color = "red",
    code_font_family = "Liberation Mono",
    line_spacing = 1.5,
    img_baseline_ratio = 0.3
  )

  expect_equal(props$font.size, 20)
  expect_equal(props$font.family, "Liberation Sans")
  expect_equal(props$font.color, "red")
  expect_equal(props$code.font.family, "Liberation Mono")
  expect_equal(props$line_spacing, 1.5)
  expect_equal(props$img_baseline_ratio, 0.3)
})

test_that("default_text_props has sensible defaults", {
  props <- default_text_props()

  expect_equal(props$code.font.family, "mono")
  expect_equal(props$line_spacing, 1.2)
  expect_equal(props$img_baseline_ratio, 0.15)
})

test_that("print.text_props returns invisibly", {
  props <- default_text_props()

  expect_invisible(suppressMessages(print(props)))
  expect_identical(suppressMessages(print(props)), props)
})

test_that("print.text_props produces output", {
  props <- default_text_props(font_size = 14, font_family = "Arial")

  messages <- capture.output(print(props), type = "message")
  expect_true(any(grepl("font_size", messages)))
  expect_true(any(grepl("font_family", messages)))
})

test_that("bold and italic set the default face of the text", {
  props <- default_text_props(bold = TRUE)
  expect_true(props$bold)
  expect_false(props$italic)
  ch <- md_to_chunks("a *b* `c`", text_props = props)
  words <- ch[nzchar(trimws(ch$txt)), ]
  expect_equal(words$bold, c(TRUE, TRUE, FALSE))
  expect_equal(words$italic, c(FALSE, TRUE, FALSE))
  expect_false(default_text_props()$bold)
})

test_that("element_md() uses its face", {
  plain <- ggplot2::element_grob(element_md(), label = "Some title text")
  bold <- ggplot2::element_grob(element_md(face = "bold"), label = "Some title text")
  w <- function(g) grid::convertWidth(grid::grobWidth(g), "in", valueOnly = TRUE)
  expect_gt(w(bold), w(plain))
})
