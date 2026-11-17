# munch 0.0.4

## New features

- Markdown text can contain LaTeX equations, as in R Markdown and Quarto:
`$...$` in the text, `$$...$$` alone on its line. They take the colour and
size of the surrounding text. `\$` and a dollar that does not open an
equation (`5$ and 10$`) stay dollars. Equations need the package 'equatags'
and R >= 4.3; without them, their LaTeX source is written as text, with a
warning.
- Markdown text can contain superscripts and subscripts, as in R Markdown and
Quarto: `m^2^`, `H~2~O`.
- `default_text_props()` has new arguments `bold` and `italic`.

## Changes

These changes move or resize existing texts slightly.

Text is laid out as in Word:

- Words are measured with the kerning of their font, as 'ragg', 'svglite' and
'ggiraph' draw them: right-aligned lines end at the edge and lines hold
slightly more words.
- A line has the height of its font, the single line spacing of Word. The
default line spacing is now 1 instead of 1.2, as in 'flextable'.
- Superscripts and subscripts are 65% of the font size, placed as in Word.

Texts follow the 'ggplot2' theme:

- `element_chunks()` takes the size, font, colour and face of the theme for
the chunks that do not set them, as `element_md()` does. Its argument `size`
now works.
- `geom_text_md()` and `geom_label_md()` take their default size, font,
colour and fill from the theme, as `geom_text()` and `geom_label()` do in
'ggplot2' 4.0.
- When the theme has no font family (the default), munch uses the font of
`flextable::set_flextable_defaults()` instead of `"sans"`. Set `base_family`
in the theme so that all texts of the plot share the same font.

Devices:

- `cairo_pdf()` gives a warning on Windows, where it draws text without
kerning: words are wider than measured. Use 'ragg' instead.

## Bug fixes

- `element_md()` ignored its argument `face` (#4).
- `element_md()` and `element_chunks()` ignored their left and right margins
in their width: used as `legend.text`, the widest labels were wrapped and
drawn over the next key. The y axis title is now spaced by its margin.
- Right-aligned and centred lines of wrapped text were shifted by the space
that ends them.
- With `width` and `hjust` > 0, texts were shifted to the right of their
anchor, and out of the box of labels.
- Equations created with `flextable::as_equation()` were dropped by
`chunks_grob()` and `element_chunks()`.
- `as_paragraph_md()` with an image gave a paragraph that 'flextable'
refused. An image that can not be read is now dropped with a warning.

## Dependencies

- 'ggplot2' >= 4.0.0 and 'gdtools' >= 0.6.0 are required.
- 'equatags' >= 0.4.0 is suggested, to draw equations.

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
- 'munch' now requires 'ggplot2' >= 4.0.0.

# munch 0.0.2

## Bug fixes

- `element_md()` and `element_chunks()` no longer ignore `plot.tag.position` and
`plot.tag.location` (#1).
