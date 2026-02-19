library(ggplot2)

library(gdtools)
font_set_liberation()

# Basic usage
df <- data.frame(
  x = 1:3,
  y = 1:3,
  label = c("**Bold**", "*Italic*", "`Code`")
)

if (require(ggiraph, quietly = TRUE)) {
  x <- girafe(
    ggplot(df, aes(x, y, label = label)) +
      geom_label_md(),
    options = list(opts_sizing(rescale = FALSE)),
    dependencies = list(
      liberationsansHtmlDependency(),
      liberationmonoHtmlDependency()
    )
  )

  print(x)

  x <- girafe(
    # With custom fill
    ggplot(df, aes(x, y, label = label)) +
      geom_label_md(fill = "lightyellow"),
    options = list(opts_sizing(rescale = FALSE)),
    dependencies = list(
      liberationsansHtmlDependency(),
      liberationmonoHtmlDependency()
    )
  )

  print(x)

  x <- girafe(
    # Annotation with statistics
    ggplot(mtcars, aes(mpg, wt)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE) +
      geom_label_md(
        label = "**R\u00B2 = 0.75**\n\n*p < 0.001*",
        x = 30,
        y = 5,
        hjust = 1,
        vjust = 1,
        fill = "white"
      ),
    options = list(opts_sizing(rescale = FALSE)),
    dependencies = list(
      liberationsansHtmlDependency(),
      liberationmonoHtmlDependency()
    )
  )

  print(x)
}
