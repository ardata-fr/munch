library(ggplot2)

library(gdtools)
font_set_liberation()
flextable::set_flextable_defaults(
  font.size = 12,
  font.family = "Liberation Sans"
)

p1 <- ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  labs(title = "**Bold title** with *italic*") +
  theme(plot.title = element_md())

girafe(
  ggobj = p1,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)

p2 <- ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  labs(
    title = "**MPG** vs *Weight*",
    caption = "Source: `mtcars` dataset"
  ) +
  theme(
    plot.title = element_md(size = 16),
    plot.caption = element_md(size = 9)
  )
girafe(
  ggobj = p2,
  check_fonts_dependencies = TRUE
)
