# munch: Rich Inline Text for Grid Graphics and Flextable

The 'munch' package renders rich inline text (bold, italic, code, links,
images) in grid graphics and 'ggplot2', from markdown or 'flextable'
chunks.

For 'ggplot2' integration, use
[`element_md()`](https://ardata-fr.github.io/munch/reference/element_md.md)
and
[`element_chunks()`](https://ardata-fr.github.io/munch/reference/element_chunks.md)
in theme elements, or
[`geom_text_md()`](https://ardata-fr.github.io/munch/reference/geom_text_md.md)
and
[`geom_label_md()`](https://ardata-fr.github.io/munch/reference/geom_label_md.md)
for annotations.

## Advanced usage

Use
[`md_grob()`](https://ardata-fr.github.io/munch/reference/md_grob.md) to
convert markdown text to a grid grob, or
[`chunks_grob()`](https://ardata-fr.github.io/munch/reference/chunks_grob.md)
to convert 'flextable' paragraph objects (for superscripts, subscripts,
and custom colors not available in markdown).

## Limitations

Only graphics devices that support 'systemfonts' are compatible: 'ragg',
'svglite', or 'ggiraph'. The
[`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html) device is also
supported when fonts are installed at the system level. Standard R
devices ([`pdf()`](https://rdrr.io/r/grDevices/pdf.html),
[`png()`](https://rdrr.io/r/grDevices/png.html),
[`jpeg()`](https://rdrr.io/r/grDevices/png.html)) are not compatible but
can still produce correct output if fonts are made available to the
device (e.g. via 'extrafont'). See the "Getting started" vignette for
details.

LaTeX and MathJax equations are not supported. For simple scientific
notation, use
[`as_sup()`](https://davidgohel.github.io/flextable/reference/as_sup.html)
and
[`as_sub()`](https://davidgohel.github.io/flextable/reference/as_sub.html)
from 'flextable'.

Only inline formatting is supported: bold, italic, code, strikethrough,
links, and images. Block elements such as headings, bullet lists, and
numbered lists are not available.

## Options

- `munch.skip_device_check`:

  If set to `TRUE`, the device compatibility warning is suppressed. Use
  this when you have ensured that the fonts used by 'munch' are
  available to the active graphics device (e.g. via 'extrafont' for
  [`pdf()`](https://rdrr.io/r/grDevices/pdf.html)). Set with
  `options(munch.skip_device_check = TRUE)`.

## See also

Useful links:

- <https://ardata-fr.github.io/munch/>

- <https://github.com/ardata-fr/munch>

- Report bugs at <https://github.com/ardata-fr/munch/issues>

## Author

**Maintainer**: David Gohel <david.gohel@ardata.fr>

Other contributors:

- ArData \[copyright holder\]
