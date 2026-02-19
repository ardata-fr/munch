library(flextable)

ft <- flextable(head(iris, 3))
ft <- mk_par(
  ft,
  j = 1,
  part = "body",
  value = as_paragraph_md("**Column1** has *values*")
)
ft

# With inline code
ft <- mk_par(
  ft,
  j = 2,
  part = "body",
  value = as_paragraph_md("Use `Sepal.Width` column")
)
ft
