# Changelog

## munch 0.0.5

### Bug fixes

- [`as_paragraph_md()`](https://ardata-fr.github.io/munch/dev/reference/as_paragraph_md.md):
  an image was written as “character(0)” in the HTML output of
  ‘flextable’. The image now has the alternative text of its markdown
  (`![alt](path)`), as images made by
  [`flextable::as_image()`](https://davidgohel.github.io/flextable/reference/as_image.html).

## munch 0.0.4

### New features

- Markdown text can contain LaTeX equations, as in R Markdown and
  Quarto: `$...$` in the text, `$$...$$` alone on its line. A dollar
  that does not open an equation stays a dollar. Equations need the
  package ‘equatags’ and R \>= 4.3; without them, their LaTeX source is
  written, with a warning.
- Markdown text can contain superscripts and subscripts: `m^2^`,
  `H~2~O`.
- [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  can be used for all texts of a plot: axis tick labels, labels of
  colour bars, polar axes, and the whole theme with
  `theme(text = element_md())`.
- [`as_paragraph_md()`](https://ardata-fr.github.io/munch/dev/reference/as_paragraph_md.md)
  is vectorised, as
  [`flextable::as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.html):
  each element gives the paragraph of a row, so that a column of
  markdown can be used in
  [`flextable::mk_par()`](https://davidgohel.github.io/flextable/reference/compose.html).
  A vector gave one paragraph with all its elements.
- [`default_text_props()`](https://ardata-fr.github.io/munch/dev/reference/default_text_props.md)
  has new arguments `bold` and `italic`.

### Changes

These changes move or resize existing texts slightly.

- Text is laid out as in Word: words are measured with the kerning of
  their font, a line has the height of its font (the default line
  spacing is now 1 instead of 1.2, as in ‘flextable’), superscripts and
  subscripts are 65% of the font size.
- `lineheight` is only applied between lines, as in ‘ggplot2’.
- Texts follow the ‘ggplot2’ theme:
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  takes its size, font, colour and face for the chunks that do not set
  them,
  [`geom_text_md()`](https://ardata-fr.github.io/munch/dev/reference/geom_text_md.md)
  and
  [`geom_label_md()`](https://ardata-fr.github.io/munch/dev/reference/geom_label_md.md)
  their default size, font, colour and fill. When the theme has no font
  family, munch uses the font of
  [`flextable::set_flextable_defaults()`](https://davidgohel.github.io/flextable/reference/set_flextable_defaults.html).
- [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  and
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  are S7 elements extending
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html),
  as the elements of ‘ggplot2’ 4.0. Their arguments do not change;
  `code_font_family` and `width` default to `NA` (unset).
- [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html) gives a
  warning on Windows, where it draws text without kerning. Use ‘ragg’
  instead.

### Bug fixes

Texts made with
[`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
or
[`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
are now placed as with
[`element_text()`](https://ggplot2.tidyverse.org/reference/element.html):

- axis titles follow `hjust`;
- titles at an angle that is not a right angle (`angle = 45`) are
  rotated around their anchor;
- legend titles and labels are not wrapped: long ones were broken or no
  longer aligned with their key;
- texts are placed at `vjust` in a cell higher than them: legend labels
  were drawn at the bottom of their row, below their key;
- left and right margins are counted in the width: legend labels were
  drawn over the next key;
- the margin of the labels of polar axes and `guide_axis(angle =)` are
  applied;
- `theme(axis.text = element_md())` applies to `axis.text.x` and
  `axis.text.y`.

Other fixes:

- Texts rotated by -90 degrees, such as the labels of the right strips
  of
  [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html),
  had the width of their length: the strips were too wide.
- [`geom_text_md()`](https://ardata-fr.github.io/munch/dev/reference/geom_text_md.md)
  with an `angle` drew the text away from its point.
- `nudge_x` and `nudge_y` were ignored by
  [`geom_text_md()`](https://ardata-fr.github.io/munch/dev/reference/geom_text_md.md)
  and
  [`geom_label_md()`](https://ardata-fr.github.io/munch/dev/reference/geom_label_md.md).
- [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  ignored its argument `face`
  ([\#4](https://github.com/ardata-fr/munch/issues/4)).
- Wrapped text: right-aligned and centred lines were shifted by their
  final space, and with `width` and `hjust` \> 0 texts were shifted to
  the right.
- Equations created with
  [`flextable::as_equation()`](https://davidgohel.github.io/flextable/reference/as_equation.html)
  were dropped by
  [`chunks_grob()`](https://ardata-fr.github.io/munch/dev/reference/chunks_grob.md)
  and
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md).
- [`as_paragraph_md()`](https://ardata-fr.github.io/munch/dev/reference/as_paragraph_md.md)
  with an image gave a paragraph that ‘flextable’ refused. An image that
  can not be read is now dropped with a warning.

### Dependencies

- ‘ggplot2’ \>= 4.0.4, ‘flextable’ \>= 0.10.5, ‘S7’ and ‘gdtools’ \>=
  0.6.0 are required. ‘flextable’ 0.10.5 sizes the equations of
  [`as_paragraph_md()`](https://ardata-fr.github.io/munch/dev/reference/as_paragraph_md.md)
  and draws them in
  [`flextable::gen_grob()`](https://davidgohel.github.io/flextable/reference/gen_grob.html),
  used with ‘patchwork’.
- ‘equatags’ \>= 0.4.0 is suggested, to draw equations.

## munch 0.0.3

CRAN release: 2026-11-10

### New features

- [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  and
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  have a new argument `width` to set the maximum width of the text. Use
  it with ‘patchwork’ or with a fixed aspect ratio to get titles with
  the right height (see below).

### Bug fixes

- Titles, subtitles and captions made with
  [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  or
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  could have their first lines cut at the top of the plot: their height
  was computed for the width of the plot instead of the width of their
  column. It is now computed for the width they are drawn with. With
  ‘patchwork’ or a fixed aspect ratio, this width is not known in
  advance: set `width` in these cases.
- A word wider than the available width no longer overflows: it starts
  on a new line and, if it is still too wide, it is split between
  characters (without hyphen). Images, superscripts and subscripts are
  never split.
- Consecutive line breaks now give empty lines, and spaces written after
  a line break are kept.

### Changes

- Text is now arranged into lines by
  [`flextable::layout_lines()`](https://davidgohel.github.io/flextable/reference/layout_lines.html),
  so that rich text wraps the same way in ‘munch’ and in ‘flextable’.
- SVG images are rendered at the size they are drawn, so that they stay
  sharp.

### Performance

- Lines are arranged faster.
- An image used several times is decoded only once in a session.
- The size of ‘png’, ‘jpeg’ and ‘gif’ images is read from their file
  header, without decoding them: about 15 times faster.

### Dependencies

- ‘munch’ now requires ‘flextable’ \>= 0.10.4, ‘officer’ \>= 0.7.8 and
  ‘gdtools’ \>= 0.5.3.
- ‘munch’ now requires ‘ggplot2’ \>= 4.0.0.

## munch 0.0.2

CRAN release: 2026-04-16

### Bug fixes

- [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  and
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  no longer ignore `plot.tag.position` and `plot.tag.location`
  ([\#1](https://github.com/ardata-fr/munch/issues/1)).
