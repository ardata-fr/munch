# Font recipes

## Measurement vs rendering

Using fonts with ‘munch’ involves two independent steps:

1.  **Measurement**, ‘munch’ calls
    [`gdtools::strings_sizes()`](https://davidgohel.github.io/gdtools/reference/strings_sizes.html)
    to compute text metrics (width, ascent, descent). Under the hood,
    ‘systemfonts’ locates the font file, then Cairo calculates the
    metrics. Any font registered via
    [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html),
    [`gdtools::register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html),
    [`gdtools::font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.html),
    [`gdtools::font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html)
    or
    [`gdtools::font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.html)
    is found at measurement time.

2.  **Rendering**, the graphic device draws the text. Each device has
    its own way of resolving font names. This is where mismatches
    happen: a font that measurement found may be invisible to the
    device, or vice versa.

When both steps find the same font, the output is correct. When they
disagree, text is positioned using one font’s metrics but drawn with
another ; leading to overlapping, clipping or misaligned labels.

## Which devices agree with measurement?

| Device family | Font lookup | Agrees with measurement? |
|----|----|----|
| ragg, svglite, ggiraph | ‘systemfonts’ | Always, same lookup on both sides |
| [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html), `png(type = "cairo")` | fontconfig | Only for system-installed fonts |
| [`pdf()`](https://rdrr.io/r/grDevices/pdf.html), [`png()`](https://rdrr.io/r/grDevices/png.html), [`jpeg()`](https://rdrr.io/r/grDevices/png.html) | Own engine | No guarantee, needs ‘extrafont’ |

### systemfonts devices (recommended)

Devices from ragg, svglite and ggiraph use ‘systemfonts’ for both
measurement and rendering. Every registered font is visible on both
sides.

The simplest approach is
[`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html),
which registers Liberation Sans, Serif and Mono in a single call, no
internet needed, SIL Open Font License:

``` r

library(gdtools)
font_set_liberation()
```

For system-aware detection (Arial, Helvetica, etc. with Liberation as
fallback), use
[`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.html):

``` r

font_set_auto()
```

For specific fonts (e.g. a Google Font), use
[`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.html):

``` r

library(munch)
library(ggplot2)

fonts <- font_set(sans = font_google("Open Sans"))

ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  labs(title = "**Open Sans** via *font_set()*") +
  theme_minimal(base_family = fonts$sans) +
  theme(plot.title = element_md())
```

### Cairo devices

Cairo devices ([`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html),
`png(type = "cairo")`) use the same Cairo engine for rendering as
‘gdtools’ uses for measurement. However, font lookup differs:
measurement goes through ‘systemfonts’, rendering goes through
**fontconfig**. Fontconfig only scans system-installed fonts.

This means:

- **System fonts** (e.g. Arial, Helvetica), measurement and rendering
  agree. Everything works.
- **Google Fonts** via
  [`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html),
  found by measurement but not necessarily by fontconfig, depending on
  where the cache is.
- **Liberation fonts** via
  [`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html)
  (or individual `register_liberation*()`), found by measurement only.
  Rendering falls back silently unless the fonts are also installed at
  the OS level.

Use `font_family_exists(system_only = TRUE)` to check whether a font
will be found by fontconfig:

``` r

library(gdtools)

# Found by measurement (systemfonts + registry)?
font_family_exists("sans")
#> [1] TRUE

# Found by fontconfig (system-installed only)?
font_family_exists("sans", system_only = TRUE)
#> [1] TRUE
```

### Standard R devices and extrafont

Standard devices ([`pdf()`](https://rdrr.io/r/grDevices/pdf.html),
[`png()`](https://rdrr.io/r/grDevices/png.html),
[`jpeg()`](https://rdrr.io/r/grDevices/png.html)) use their own font
engine and ignore ‘systemfonts’ entirely.

‘munch’ uses ‘gdtools’ (which relies on Cairo) for text measurement. The
standard [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) device uses its
own font engine. For the output to be correct, the fonts used by ‘munch’
must also be known to [`pdf()`](https://rdrr.io/r/grDevices/pdf.html).

The ‘extrafont’ package bridges this gap: it imports TrueType fonts into
R’s PDF device by generating font metric files that
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) can use.

**The key requirement**: every font used in the plot must be available
to both ‘systemfonts’ (for measurement) and
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html) (for rendering). If a
font is registered with ‘systemfonts’ but not with
[`pdf()`](https://rdrr.io/r/grDevices/pdf.html), the text metrics will
not match the rendering and the output will have positioning errors.

#### Example: exporting a munch plot to PDF

``` r

library(gdtools)
library(munch)
library(ggplot2)

df <- data.frame(
  x = 1:3,
  y = 1:3,
  label = c("**Bold**", "*Italic*", "`Code`")
)

p <- ggplot(df, aes(x, y, label = label)) +
  geom_label_md(code_font_family = "Courier New") +
  theme_minimal(base_family = "Arial")

# Make Arial and Courier New available to pdf()
library(extrafont)
# font_import()
# Run font_import() once to scan system fonts,
# then loadfonts() in each session.
loadfonts()

# Suppress the device warning since we ensured font concordance
options(munch.skip_device_check = TRUE)

pdf(file = "munch-example.pdf", width = 7, height = 7)
print(p)
dev.off()
```

The steps are:

1.  **Install fonts at the system level**, both “Arial” and “Courier
    New” must be installed as system fonts.
2.  **Import fonts once** with `extrafont::font_import()`, this scans
    system fonts and creates metric files for
    [`pdf()`](https://rdrr.io/r/grDevices/pdf.html). Only needed once.
3.  **Load fonts each session** with `extrafont::loadfonts()`, this
    registers the imported fonts with
    [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) for the current
    session.
4.  **Disable the device check** with
    `options(munch.skip_device_check = TRUE)`, since you have ensured
    font concordance manually, the warning is no longer needed.

> **Note**: [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html) is a
> simpler alternative. It uses Cairo for rendering (same engine as
> ‘gdtools’ for measurement), so system-installed fonts work without
> ‘extrafont’. Use [`pdf()`](https://rdrr.io/r/grDevices/pdf.html) +
> ‘extrafont’ only when
> [`cairo_pdf()`](https://rdrr.io/r/grDevices/cairo.html) is not
> available.

## Font sources at a glance

| Font source | Measurement | ragg / svglite / ggiraph | Cairo devices | pdf() / png() |
|----|----|----|----|----|
| System font | Yes | Yes | Yes | Via extrafont |
| [`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html) | Yes | Yes | Depends on cache location | No |
| [`font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html) | Yes | Yes | No (unless OS-installed) | No |
| [`font_set_auto()`](https://davidgohel.github.io/gdtools/reference/font_set_auto.html) | Yes | Yes | System fonts only | No |
| [`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.html) | Yes | Yes | System fonts only | No |

## Diagnosing font problems

When text looks wrong (wrong font, misaligned labels), the cause is
almost always a measurement/rendering disagreement. Here is a quick
checklist:

1.  **Is the font found by measurement?**

    ``` r

    gdtools::font_family_exists("My Font")
    ```

    If `FALSE`: the font is not registered with ‘systemfonts’. Register
    it with
    [`register_gfont()`](https://davidgohel.github.io/gdtools/reference/register_gfont.html),
    [`font_set()`](https://davidgohel.github.io/gdtools/reference/font_set.html),
    or
    [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html).

2.  **Is the font found by the device?**

    - For Cairo devices:

      ``` r

      gdtools::font_family_exists("My Font", system_only = TRUE)
      ```

      If `FALSE`: the font is not system-installed. Either install it at
      the OS level or switch to a ‘systemfonts’ device (ragg, svglite).

    - For [`pdf()`](https://rdrr.io/r/grDevices/pdf.html): check that
      `extrafont::fonts()` includes the family.

    - For ragg/svglite/ggiraph: if step 1 passed, this always works.

3.  **Do both sides find the *same* font?** Even when both find a font,
    it may not be the same file (e.g. a different weight or a
    substitution). Compare:

    ``` r

    # What systemfonts resolves
    systemfonts::match_fonts("My Font")

    # What's installed at the system level
    subset(systemfonts::system_fonts(), family == "My Font")
    ```
