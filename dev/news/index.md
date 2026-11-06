# Changelog

## munch (development version)

- Lines are now arranged by
  [`flextable::layout_lines()`](https://davidgohel.github.io/flextable/reference/layout_lines.html),
  as in ‘flextable’, and faster. Consecutive line breaks give empty
  lines, and spaces written after a line break are kept. It needs
  ‘flextable’ \>= 0.10.4.
- Images are decoded once in a session with
  [`flextable::image_raster()`](https://davidgohel.github.io/flextable/reference/image_raster.html),
  and drawn faster. SVG images are rendered at the size they are drawn.
- A word wider than `width` now starts on a new line and is split
  between characters if it is still too wide, without hyphen, as in
  ‘flextable’. It used to overflow. Images, superscripts and subscripts
  are not split.

## munch 0.0.2

CRAN release: 2026-04-16

- Fixed
  [`element_md()`](https://ardata-fr.github.io/munch/dev/reference/element_md.md)
  and
  [`element_chunks()`](https://ardata-fr.github.io/munch/dev/reference/element_chunks.md)
  ignoring `plot.tag.position` and `plot.tag.location`
  ([\#1](https://github.com/ardata-fr/munch/issues/1)).
