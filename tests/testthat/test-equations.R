skip_if_not(munch:::can_draw_equations())

equation_paragraph <- function(...) {
  flextable::as_paragraph("Area: ", flextable::as_equation(...), " m")
}

test_that("an equation chunk is measured with equatags", {
  gdtools::font_set_liberation()
  gr <- chunks_grob(equation_paragraph("\\pi r^2"))
  eq <- gr$chunks[!is.na(gr$chunks$eq_data), ]
  expected <- equatags::equation_size("\\pi r^2", size = eq$font.size)
  expect_equal(nrow(eq), 1L)
  expect_equal(eq$width, expected$width)
  expect_equal(eq$ascent, expected$height)
  expect_equal(eq$descent, expected$depth)
  # the equation counts in the width of the grob
  without <- chunks_grob(flextable::as_paragraph("Area: ", " m"))
  expect_equal(dim(gr)$width - dim(without)$width, expected$width, tolerance = 1e-6)
})

test_that("an equation is drawn on the baseline of its line", {
  gdtools::font_set_liberation()
  gr <- chunks_grob(equation_paragraph("\\pi r^2"))
  content <- grid::makeContent(gr)
  is_eq <- grepl("^equation_", names(content$children))
  expect_equal(sum(is_eq), 1L)
  eq_grob <- content$children[[which(is_eq)]]
  text_grob <- content$children[[which(grepl("^chunk_", names(content$children)))[1]]]
  # same baseline as the text: y0 is the baseline when vjust is the share of
  # the depth in the height of the equation
  eq <- gr$chunks[!is.na(gr$chunks$eq_data), ]
  expect_equal(
    grid::convertY(eq_grob$y0, "inches", valueOnly = TRUE),
    grid::convertY(text_grob$y, "inches", valueOnly = TRUE)
  )
  expect_equal(eq_grob$vjust, eq$descent / (eq$ascent + eq$descent))
})

test_that("a fraction makes its line higher", {
  gdtools::font_set_liberation()
  plain <- chunks_grob(flextable::as_paragraph("Area: m"))
  frac <- chunks_grob(equation_paragraph("\\frac{a+b}{c}"))
  expect_gt(dim(frac)$height, dim(plain)$height)
})

test_that("an equation takes the colour and the size of its chunk", {
  gdtools::font_set_liberation()
  props <- officer::fp_text_lite(color = "red", font.size = 20)
  gr <- chunks_grob(flextable::as_paragraph(flextable::as_equation("x^2", props = props)))
  eq <- gr$chunks[!is.na(gr$chunks$eq_data), ]
  expect_equal(eq$color, "red")
  expect_equal(eq$width, equatags::equation_size("x^2", size = 20)$width)
})

test_that("equations are written as LaTeX source when they can not be drawn", {
  gdtools::font_set_liberation()
  local_mocked_bindings(can_draw_equations = function() FALSE)
  withr::local_options(rlib_warning_verbosity = "verbose")
  expect_warning(
    gr <- chunks_grob(equation_paragraph("\\pi r^2")),
    "LaTeX source"
  )
  expect_true(any(gr$chunks$txt %in% "$\\pi r^2$"))
  expect_true(all(is.na(gr$chunks$eq_data)))
})
