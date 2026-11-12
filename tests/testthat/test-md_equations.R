# Equations in markdown, found with the rules of Pandoc (results checked
# with Pandoc 3 and its extension tex_math_dollars).

eqs <- function(x) {
  ch <- md_to_chunks(x)
  is_eq <- !is.na(ch$eq_data)
  data.frame(
    tex = ch$eq_data[is_eq],
    display = ch$eq_display[is_eq] %in% TRUE,
    stringsAsFactors = FALSE
  )
}
texts <- function(x) {
  ch <- md_to_chunks(x)
  ch$txt[!is.na(ch$txt)]
}

test_that("inline equations become equation chunks", {
  ch <- md_to_chunks("Area $\\pi r^2$ of a disc.")
  expect_equal(ch$txt, c("Area ", NA, " of a disc."))
  expect_equal(ch$eq_data, c(NA, "\\pi r^2", NA))
  expect_false(ch$eq_display[2])
})

test_that("markdown does not read the content of equations", {
  expect_equal(eqs("$x_1 * y_2 * z_3$")$tex, "x_1 * y_2 * z_3")
  expect_equal(eqs("$a_{i}^{*}$ and *b*")$tex, "a_{i}^{*}")
  expect_true(md_to_chunks("$a_{i}^{*}$ and *b*")$italic[3])
})

test_that("dollars that are not equations are kept", {
  x <- "It costs 5$ and 10$, or $20,000 and $30,000."
  expect_equal(nrow(eqs(x)), 0L)
  expect_equal(texts(x), x)
  # spaces inside the dollars
  expect_equal(eqs("$ x$ not math, $x $ not math, $x$ math.")$tex, "x")
  # a digit after the closing dollar
  expect_equal(eqs("$x$5 and $y$")$tex, "y")
  # an unclosed dollar
  expect_equal(texts("a $x"), "a $x")
})

test_that("an escaped dollar is a dollar", {
  expect_equal(nrow(eqs("A \\$ and \\$")), 0L)
  expect_equal(texts("A \\$ and \\$"), "A $ and $")
  # inside an equation, it is a dollar of LaTeX
  expect_equal(eqs("Escaped $a \\$ b$ inside.")$tex, "a \\$ b")
})

test_that("there are no equations in code", {
  expect_equal(nrow(eqs("`code $x$` here")), 0L)
  expect_equal(texts("`code $x$` here")[1], "code $x$")
  expect_equal(eqs("``a ` $b$`` and $c$")$tex, "c")
})

test_that("an equation does not span paragraphs", {
  x <- "Para $x\n\nb$ two."
  expect_equal(nrow(eqs(x)), 0L)
  expect_equal(eqs("A $x\ny$ b")$tex, "x\ny")
})

test_that("display equations are alone on their line", {
  ch <- md_to_chunks("Text before $$\\sum_{i=1}^n x_i$$ after.")
  expect_equal(ch$txt, c("Text before", "\n", NA, "\n", "after."))
  expect_equal(ch$eq_data[3], "\\sum_{i=1}^n x_i")
  expect_true(ch$eq_display[3])

  ch <- md_to_chunks("Text\n$$ x $$\nafter")
  expect_equal(ch$txt, c("Text", "\n", NA, "\n", "after"))
  expect_equal(ch$eq_data[3], "x")

  ch <- md_to_chunks("$$x$$")
  expect_equal(nrow(ch), 1L)
  expect_true(ch$eq_display)

  expect_equal(texts("a $$ b"), "a $$ b")
})

test_that("equations take the size and the colour of their text", {
  props <- default_text_props(font_size = 20, font_color = "red")
  ch <- md_to_chunks("**$x$** and [$y$](https://a.b)", text_props = props)
  eq <- ch[!is.na(ch$eq_data), ]
  expect_equal(eq$font.size, c(20, 20))
  expect_equal(eq$color, c("red", "#0066cc"))
})

test_that("equations of markdown are drawn", {
  skip_if_not(munch:::can_draw_equations())
  gdtools::font_set_liberation()
  gr <- md_grob("Area $\\pi r^2$ and $$\\frac{a}{b}$$")
  content <- grid::makeContent(gr)
  expect_equal(sum(grepl("^equation_", names(content$children))), 2L)
  # two lines: the text with the inline equation, the display equation
  lines <- munch:::arrange_chunks_into_lines(gr$chunks)
  expect_length(lines, 2L)
})

test_that("as_paragraph_md() gives equations to flextable", {
  p <- as_paragraph_md("Area $\\pi r^2$ and $$x$$")
  expect_true(flextable:::is_paragraph(p[[1]]))
  expect_equal(sum(!is.na(p[[1]]$eq_data)), 2L)
  ft <- flextable::flextable(data.frame(a = 1))
  ft <- flextable::mk_par(ft, j = "a", value = p)
  expect_s3_class(ft, "flextable")
})
