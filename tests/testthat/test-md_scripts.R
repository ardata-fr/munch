# Superscripts ^...^ and subscripts ~...~ of Pandoc (results checked with
# Pandoc 3 and its extensions superscript and subscript).

aligned <- function(x) {
  ch <- md_to_chunks(x)
  keep <- !is.na(ch$txt)
  data.frame(txt = ch$txt[keep], va = ch$vertical.align[keep], stringsAsFactors = FALSE)
}

test_that("superscripts and subscripts are read", {
  d <- aligned("H~2~O and 2^10^")
  expect_equal(d$txt, c("H", "2", "O and 2", "10"))
  expect_equal(d$va, c("baseline", "subscript", "baseline", "superscript"))
  d <- aligned("x^1,2^ y~i,j~ m^-1^")
  expect_equal(d$txt[d$va != "baseline"], c("1,2", "i,j", "-1"))
})

test_that("delimiters that are not scripts are kept", {
  expect_equal(aligned("x^2 alone")$txt, "x^2 alone")
  expect_equal(aligned("^a b^ no")$txt, "^a b^ no")
  expect_equal(aligned("a~b")$txt, "a~b")
  expect_equal(aligned("^^ and ~ ~")$txt, "^^ and ~ ~")
  d <- aligned("~a~b~")
  expect_equal(d$txt, c("a", "b~"))
  expect_equal(d$va, c("subscript", "baseline"))
  d <- aligned("^2^3^")
  expect_equal(d$txt, c("2", "3^"))
})

test_that("an escaped space is a space of the script", {
  d <- aligned("^a\\ b^ yes")
  expect_equal(d$txt, c("a b", " yes"))
  expect_equal(d$va, c("superscript", "baseline"))
})

test_that("~~ is a strikethrough, ~ a subscript", {
  ch <- md_to_chunks("~~strike~~ and ~sub~")
  expect_equal(ch$txt, c("strike", " and ", "sub"))
  expect_equal(ch$strike, c(TRUE, FALSE, FALSE))
  expect_equal(ch$vertical.align, c("baseline", "baseline", "subscript"))
})

test_that("markdown is read inside scripts", {
  ch <- md_to_chunks("^*a*^ and ~**b**~")
  expect_equal(ch$txt, c("a", " and ", "b"))
  expect_equal(ch$vertical.align, c("superscript", "baseline", "subscript"))
  expect_equal(ch$italic, c(TRUE, FALSE, FALSE))
  expect_equal(ch$bold, c(FALSE, FALSE, TRUE))
  d <- aligned("[link^2^](https://a.b)")
  expect_equal(d$va, c("baseline", "superscript"))
})

test_that("there are no scripts in code and equations", {
  expect_equal(aligned("see `x^2^` code")$txt, c("see ", "x^2^", " code"))
  expect_equal(md_to_chunks("$x^2^y$ and ^2^")$eq_data[1], "x^2^y")
})

test_that("as_paragraph_md() gives scripts to flextable", {
  p <- as_paragraph_md("CO~2~ in m^3^")
  expect_true(flextable:::is_paragraph(p[[1]]))
  expect_equal(
    p[[1]]$vertical.align,
    c("baseline", "subscript", "baseline", "superscript")
  )
})
