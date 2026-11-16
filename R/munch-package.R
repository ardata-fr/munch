#' @title munch: Rich Inline Text for Grid Graphics and Flextable
#'
#' @description
#' The 'munch' package renders rich inline text (bold, italic, code,
#' links, images, equations) in grid graphics and 'ggplot2', from markdown or
#' 'flextable' chunks.
#'
#' For 'ggplot2' integration, use [element_md()] and [element_chunks()] in
#' theme elements, or [geom_text_md()] and [geom_label_md()] for annotations.
#'
#' @section Advanced usage:
#'
#' Use [md_grob()] to convert markdown text to a grid grob, or [chunks_grob()]
#' to convert 'flextable' paragraph objects (for superscripts, subscripts,
#' and custom colors not available in markdown).
#'
#' @section Limitations:
#'
#' Only graphics devices that support 'systemfonts' are compatible:
#' 'ragg', 'svglite', or 'ggiraph'. The [cairo_pdf()] device is also
#' supported when fonts are installed at the system level, except on
#' Windows, where it does not apply the kerning of the fonts: words are
#' drawn wider than measured.
#' Standard R devices ([pdf()], [png()], [jpeg()]) are not compatible
#' but can still produce correct output if fonts are made available
#' to the device (e.g. via 'extrafont'). See `vignette("font-recipes")`
#' for details.
#'
#' Equations, written `$...$` and `$$...$$` in markdown (as in Pandoc) or
#' created with `flextable::as_equation()`, are drawn with the package
#' 'equatags' (R >= 4.3); without it, their LaTeX source is written as text.
#' A `$$...$$` equation is alone on its line, in display style. For simple
#' scientific notation, `as_sup()` and `as_sub()` from 'flextable' are
#' enough.
#'
#' Only inline formatting is supported: bold, italic, code, strikethrough,
#' links, images, superscripts (`^2^`), subscripts (`~2~`) and equations.
#' Superscripts, subscripts and equations follow the markdown of Pandoc
#' (R Markdown, Quarto). Block elements such as headings, bullet lists, and
#' numbered lists are not available.
#'
#' @section Options:
#'
#' \describe{
#'   \item{`munch.skip_device_check`}{If set to `TRUE`, the device
#'   compatibility warning is suppressed. Use this when you have
#'   ensured that the fonts used by 'munch' are available to the
#'   active graphics device (e.g. via 'extrafont' for [pdf()]).
#'   Set with `options(munch.skip_device_check = TRUE)`.}
#' }
#'
#' @docType package
#' @aliases munch-package
#' @name munch-package
"_PACKAGE"

## usethis namespace: start
#' @importFrom grid gpar gTree gList textGrob unit viewport grid.layout
#' @importFrom grid makeContext setChildren convertWidth convertHeight
#' @importFrom grid nullGrob widthDetails heightDetails rectGrob rasterGrob
#' @importFrom grid vpStack unit.c unitType
#' @importFrom gdtools strings_sizes
#' @importFrom methods slot
## usethis namespace: end
NULL

#' Check if the current graphics device is compatible with munch
#'
#' Warns if the current device is not known to support
#' systemfonts (ragg, svglite, ggiraph, cairo_pdf), or if it is
#' `cairo_pdf()` in a build of R without 'Pango', where words are drawn
#' without the kerning applied by the measures.
#'
#' @return NULL invisibly.
#' @noRd
check_device_compatibility <- function() {
  if (isTRUE(getOption("munch.skip_device_check"))) {
    return(invisible(NULL))
  }

  dev_name <- names(grDevices::dev.cur())

  # Patterns for compatible device names (using startsWith for flexibility)
  compatible_patterns <- c(
    # ragg devices (may have numeric suffix like agg_capture_123456)
    "agg_png",
    "agg_tiff",
    "agg_jpeg",
    "agg_ppm",
    "agg_capture",
    # svglite
    "devSVG",
    # ggiraph
    "dsvg_device",
    # null device (for testing)
    "null device"
  )
  if ("ragg" %in% getOption("RStudioGD.backend")) {
    compatible_patterns <- c(compatible_patterns, "RStudioGD")
  }

  is_compatible <- any(vapply(
    compatible_patterns,
    function(pattern) startsWith(dev_name, pattern),
    logical(1)
  ))

  if (startsWith(dev_name, "cairo_pdf")) {
    if (!cairo_has_pango()) {
      cli::cli_warn(
        c(
          "!" = paste0(
            "{.fun cairo_pdf} does not kern in this build of R ",
            "(no {.pkg Pango}, as on Windows): words are drawn wider than ",
            "{.pkg munch} measures them."
          ),
          "i" = "Recommended devices: {.pkg ragg}, {.pkg svglite}, {.pkg ggiraph}."
        ),
        .frequency = "once",
        .frequency_id = "munch_device_cairo_kerning"
      )
    }
    return(invisible(NULL))
  }

  if (!is_compatible) {
    recommended <- "{.pkg ragg}, {.pkg svglite}, {.pkg ggiraph}"
    if (cairo_has_pango()) {
      recommended <- paste0(recommended, ", {.fun cairo_pdf}")
    }
    cli::cli_warn(
      c(
        "!" = paste0(
          "Current graphics device ({.val {dev_name}}) ",
          "may not be fully compatible with {.pkg munch}."
        ),
        "i" = paste0(
          "{.pkg munch} uses {.pkg systemfonts} and works best ",
          "with compatible devices."
        ),
        "i" = paste0("Recommended devices: ", recommended, ".")
      ),
      .frequency = "once",
      .frequency_id = "munch_device_compat"
    )
  }

  invisible(NULL)
}

#' Does R draw the text of Cairo devices with Pango?
#'
#' Without 'Pango' (Windows builds of R), Cairo devices draw text with the
#' 'toy' interface of Cairo, which does not kern.
#'
#' @return A logical.
#' @noRd
cairo_has_pango <- function() {
  isTRUE(nzchar(grDevices::grSoftVersion()["pango"]))
}
