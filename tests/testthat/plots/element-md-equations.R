# equations in markdown: inline in a title, display in a subtitle, in bold
# text (the equation stays normal), in a text layer
list(
  plot = ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
    ggplot2::geom_point() +
    geom_text_md(
      data = data.frame(mpg = 25, wt = 5, label = "**Fit** $y = ax + b$"),
      ggplot2::aes(label = label)
    ) +
    ggplot2::labs(
      title = "Area of a disc: $A = \\pi r^2$, ratio $\\frac{a+b}{c}$",
      subtitle = "**Mean** $$\\bar{x} = \\frac{1}{n}\\sum_{i=1}^n x_i$$ of $n$ values",
      caption = "It costs 5$ and 10$, and \\$x\\$ is not an equation"
    ) +
    base_theme() +
    ggplot2::theme(
      plot.title = element_md(),
      plot.subtitle = element_md(),
      plot.caption = element_md()
    ),
  width = 6,
  height = 5
)
