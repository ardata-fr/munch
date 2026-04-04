# Patchwork Annotation with Rich Text

A replacement for
[`patchwork::plot_annotation()`](https://patchwork.data-imaginist.com/reference/plot_annotation.html)
that supports
[`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
and
[`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
for the title, subtitle, and/or caption of a combined patchwork plot.

Each text argument accepts:

- An
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  or
  [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  object — rendered as rich text with auto-wrapping; all formatting
  options (hjust, lineheight, margin, etc.) are set inside the element
  call.

- A bare
  [`flextable::as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.html)
  object — wrapped in
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  with default settings.

- A plain character string — passed through unchanged.

- `NULL` — element omitted.

Patchwork only renders an annotation element when a non-NULL string is
provided to
[`patchwork::plot_annotation()`](https://patchwork.data-imaginist.com/reference/plot_annotation.html).
For element/chunks-based inputs, `munch_annotation` supplies an
invisible sentinel string so patchwork creates the layout row, while
[`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
or
[`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
handles the actual rendering using the stored content (the label is
ignored).

## Usage

``` r
munch_annotation(
  caption = NULL,
  title = NULL,
  subtitle = NULL,
  tag_levels = NULL,
  tag_prefix = NULL,
  tag_suffix = NULL,
  tag_sep = NULL,
  theme = NULL
)
```

## Arguments

- caption:

  An
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md),
  [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md),
  [`flextable::as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.html)
  object, a plain character string, or `NULL`.

- title:

  Same as `caption`.

- subtitle:

  Same as `caption`.

- tag_levels, tag_prefix, tag_suffix, tag_sep:

  Passed through to
  [`patchwork::plot_annotation()`](https://patchwork.data-imaginist.com/reference/plot_annotation.html).

- theme:

  Additional
  [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
  elements merged on top of any element themes derived from `title`,
  `subtitle`, or `caption`.

## Value

An object of class `c("munch_annotation", "gg")` that can be added to a
patchwork object with `+`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
library(patchwork)
library(flextable)

p1 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
p2 <- ggplot(mtcars, aes(hp, wt)) + geom_point()

caption_chunks <- as_paragraph(
  as_chunk("R"), as_sup("2"), as_chunk(" = 0.75")
)

wrap_plots(p1, p2) +
  munch_annotation(
    title   = "A plain string title",
    caption = element_chunks(caption_chunks, lineheight = 1.5, hjust = 0)
  )
} # }
```
