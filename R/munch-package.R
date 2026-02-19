#' @title munch: Rich Inline Text for Grid Graphics and Flextable
#'
#' @description
#' The 'munch' package renders rich inline text (bold, italic, code,
#' links, images) in grid graphics and 'ggplot2', from markdown or
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
#' supported when fonts are installed at the system level.
#' Standard R devices ([pdf()], [png()], [jpeg()]) are not compatible
#' but can still produce correct output if fonts are made available
#' to the device (e.g. via 'extrafont'). See the "Getting started" vignette
#' for details.
#'
#' LaTeX and MathJax equations are not supported. For simple scientific
#' notation, use `as_sup()` and `as_sub()` from 'flextable'.
#'
#' Only inline formatting is supported: bold, italic, code, strikethrough,
#' links, and images. Block elements such as headings, bullet lists, and
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
#' @importFrom grid vpStack unit.c
#' @importFrom gdtools strings_sizes
#' @importFrom methods slot
## usethis namespace: end
NULL

#' Check if the current graphics device is compatible with munch
#'
#' Aborts if the current device is not known to support
#' systemfonts (ragg, svglite, ggiraph, cairo_pdf).
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
    # cairo
    "cairo_pdf",
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

  if (!is_compatible) {
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
        "i" = "Recommended devices: {.pkg ragg}, {.pkg svglite}, {.pkg ggiraph}, {.fun cairo_pdf}."
      ),
      .frequency = "once",
      .frequency_id = "munch_device_compat"
    )
  }

  invisible(NULL)
}
