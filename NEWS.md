# munch (development version)

- Lines are now arranged by `flextable::layout_lines()`, as in 'flextable', and
faster. Consecutive line breaks give empty lines, and spaces written after a line
break are kept. It needs 'flextable' >= 0.10.4.
- Images are decoded once in a session with `flextable::image_raster()`, and drawn
faster. SVG images are rendered at the size they are drawn.
- A word wider than `width` now starts on a new line and is split between
characters if it is still too wide, without hyphen, as in 'flextable'. It used to
overflow. Images, superscripts and subscripts are not split.
- The height of titles, subtitles and captions made with `element_md()` or
`element_chunks()` is now computed for the width they are drawn with, the one of
their column. It was computed for the width of the plot, so that their first lines
could be cut at the top of the plot. This is not possible with 'patchwork', and is
only an improvement with a fixed aspect ratio.
- New argument `width` in `element_md()` and `element_chunks()` to set the maximum
width of the text, which also gives the right height with 'patchwork' and with a
fixed aspect ratio.

# munch 0.0.2

- Fixed `element_md()` and `element_chunks()` ignoring `plot.tag.position` and `plot.tag.location` (#1).
