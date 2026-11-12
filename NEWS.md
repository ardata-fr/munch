# munch 0.0.4

## Changes

- Words are measured with the kerning of their font
(`gdtools::strings_sizes(kerning = TRUE)`), as 'ragg', 'svglite' and 'ggiraph'
draw them: spaces after kerned words are no longer too wide and right-aligned
lines end at the right edge. Lines can contain slightly more words. Requires
'gdtools' >= 0.6.0.
- Line spacing follows Word: the height of a line is the line height of its
font (`gdtools::font_line_metrics()`, the single line spacing of Word), and a
line spacing larger than 1 adds its space below the line. It was computed from
the ink of the glyphs, so that lines almost touched with a line spacing of 1.
The default line spacing is now the one of `flextable::get_flextable_defaults()`
(1) instead of 1.2, also for the `lineheight` of `geom_text_md()` and
`geom_label_md()`. Texts are a bit more spaced than before.

## Bug fixes

- `element_md()` now uses its argument `face` ("bold", "italic",
"bold.italic"): it was ignored (#4). Markdown emphasis adds to it.
`default_text_props()` has new arguments `bold` and `italic`.
- With `width` and `hjust` > 0, the text of `md_grob()`, `chunks_grob()`,
`geom_text_md()` and `geom_label_md()` was shifted to the right of its anchor,
and out of the box of labels.

# munch 0.0.3

## New features

- `element_md()` and `element_chunks()` have a new argument `width` to set the
maximum width of the text. Use it with 'patchwork' or with a fixed aspect ratio
to get titles with the right height (see below).

## Bug fixes

- Titles, subtitles and captions made with `element_md()` or `element_chunks()`
could have their first lines cut at the top of the plot: their height was
computed for the width of the plot instead of the width of their column. It is
now computed for the width they are drawn with. With 'patchwork' or a fixed
aspect ratio, this width is not known in advance: set `width` in these cases.
- A word wider than the available width no longer overflows: it starts on a new
line and, if it is still too wide, it is split between characters (without
hyphen). Images, superscripts and subscripts are never split.
- Consecutive line breaks now give empty lines, and spaces written after a line
break are kept.

## Changes

- Text is now arranged into lines by `flextable::layout_lines()`, so that rich
text wraps the same way in 'munch' and in 'flextable'.
- SVG images are rendered at the size they are drawn, so that they stay sharp.

## Performance

- Lines are arranged faster.
- An image used several times is decoded only once in a session.
- The size of 'png', 'jpeg' and 'gif' images is read from their file header,
without decoding them: about 15 times faster.

## Dependencies

- 'munch' now requires 'flextable' >= 0.10.4, 'officer' >= 0.7.8 and 'gdtools'
>= 0.5.3.

# munch 0.0.2

## Bug fixes

- `element_md()` and `element_chunks()` no longer ignore `plot.tag.position` and
`plot.tag.location` (#1).
