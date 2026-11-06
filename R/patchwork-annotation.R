#' @title Patchwork Annotation with Rich Text
#' @description
#' A replacement for [patchwork::plot_annotation()] that supports
#' [element_chunks()] and [element_md()] for the title, subtitle, and/or
#' caption of a combined patchwork plot.
#'
#' Each text argument accepts:
#' - An [element_chunks()] or [element_md()] object — rendered as rich text
#'   with auto-wrapping; all formatting options (hjust, lineheight, margin,
#'   etc.) are set inside the element call.
#' - A bare [flextable::as_paragraph()] object — wrapped in [element_chunks()]
#'   with default settings.
#' - A plain character string — passed through unchanged.
#' - `NULL` — element omitted.
#'
#' Patchwork only renders an annotation element when a non-NULL string is
#' provided to [patchwork::plot_annotation()]. For element/chunks-based inputs,
#' `munch_annotation` supplies an invisible sentinel string so patchwork
#' creates the layout row, while [element_chunks()] or [element_md()] handles
#' the actual rendering using the stored content (the label is ignored).
#'
#' @param caption An [element_chunks()], [element_md()],
#'   [flextable::as_paragraph()] object, a plain character string, or `NULL`.
#' @param title Same as `caption`.
#' @param subtitle Same as `caption`.
#' @param tag_levels,tag_prefix,tag_suffix,tag_sep Passed through to
#'   [patchwork::plot_annotation()].
#' @param theme Additional [ggplot2::theme()] elements merged on top of any
#'   element themes derived from `title`, `subtitle`, or `caption`.
#'
#' @return An object of class `c("munch_annotation", "gg")` that can be added
#'   to a patchwork object with `+`.
#' @export
#' @examplesIf require("patchwork", quietly = TRUE) && require("ggiraph", quietly = TRUE)
#' library(ggplot2)
#' library(patchwork)
#' library(flextable)
#'
#' library(gdtools)
#' font_set_liberation()
#' set_flextable_defaults(
#'   font.size = 12,
#'   font.family = "Liberation Sans"
#' )

#' p1 <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
#' p2 <- ggplot(mtcars, aes(hp, wt)) + geom_point()
#'
#' caption_chunks <- as_paragraph(
#'   as_chunk("R"), as_sup("2"), as_chunk(" = 0.75")
#' )
#'
#' plot_obj <- wrap_plots(p1, p2) +
#'   munch_annotation(
#'     title   = "A plain string title",
#'     caption = element_chunks(caption_chunks, lineheight = 1.5, hjust = 0)
#'   )
#' x <- girafe(
#'   plot_obj,
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#' x
munch_annotation <- function(
  caption = NULL,
  title = NULL,
  subtitle = NULL,
  tag_levels = NULL,
  tag_prefix = NULL,
  tag_suffix = NULL,
  tag_sep = NULL,
  theme = NULL
) {
  .check_annotation_arg <- function(x, arg) {
    ok <- is.null(x) ||
      is.character(x) ||
      inherits(x, c("paragraph", "chunk", "element_chunks", "element_md"))
    if (!ok) {
      cli::cli_abort(c(
        "{.arg {arg}} must be one of:",
        "*" = "a character string",
        "*" = "an {.fn element_chunks} or {.fn element_md} object",
        "*" = "a {.fn as_paragraph} / chunk object from 'flextable'",
        "*" = "NULL"
      ))
    }
  }
  .check_annotation_arg(caption, "caption")
  .check_annotation_arg(title, "title")
  .check_annotation_arg(subtitle, "subtitle")

  structure(
    list(
      caption = caption,
      title = title,
      subtitle = subtitle,
      tag_levels = tag_levels,
      tag_prefix = tag_prefix,
      tag_suffix = tag_suffix,
      tag_sep = tag_sep,
      theme = theme
    ),
    class = c("munch_annotation", "gg")
  )
}

# TRUE if x is a munch element that self-contains its content (ignores label)
.is_munch_element <- function(x) inherits(x, c("element_chunks", "element_md"))

# TRUE if x is a bare flextable paragraph/chunk (needs wrapping)
.is_chunks <- function(x) inherits(x, c("paragraph", "chunk"))

# Resolve an annotation argument to:
#   list(element = <theme element or NULL>, sentinel = <string or NULL>)
.resolve_annotation <- function(x) {
  if (is.null(x)) {
    list(element = NULL, sentinel = NULL)
  } else if (.is_munch_element(x)) {
    list(element = x, sentinel = " ")
  } else if (.is_chunks(x)) {
    list(element = element_chunks(x), sentinel = " ")
  } else {
    # plain character string — no custom element needed
    list(element = NULL, sentinel = x)
  }
}

# --- Patchwork sentinel workaround -------------------------------------------
#
# patchwork::annotate_table() only adds a caption/title/subtitle row to its
# combined gtable when the corresponding field in the annotation list is
# non-NULL (e.g. `if (!is.null(annotation$caption))`). The field is populated
# by the plain text argument to plot_annotation(), not by the theme.
#
# When a munch element (element_chunks / element_md) is used, the text content
# is stored inside the element object itself, so no caption string is passed to
# plot_annotation(). Without a non-NULL string, patchwork silently skips the
# layout row and element_grob() is never called.
#
# This means that we need to call plot_annotation with a dummy string and pass
# the element_chunk to the theme
#   p + patchwork::plot_annotation(
#     caption = "dummy string",
#     theme = theme(plot.caption = element_chunk(chunk_caption))
#   )
#
# Workaround: pass a single space (" ") as a sentinel string for every
# chunks/md-based argument. This satisfies patchwork's non-NULL check so it
# creates the layout row and calls element_grob(). element_grob.element_chunks
# and element_grob.element_md both ignore the `label` argument entirely and
# render from their stored chunks/markdown instead, so the sentinel is never
# visible in the output.
# -----------------------------------------------------------------------------

#' @importFrom patchwork plot_annotation
#' @importFrom ggplot2 ggplot_add
#' @exportS3Method ggplot2::ggplot_add
ggplot_add.munch_annotation <- function(object, plot, ...) {
  cap <- .resolve_annotation(object$caption)
  ttl <- .resolve_annotation(object$title)
  sub <- .resolve_annotation(object$subtitle)

  # Build theme entries for any munch elements
  theme_parts <- list()
  if (!is.null(cap$element)) {
    theme_parts$plot.caption <- cap$element
  }
  if (!is.null(ttl$element)) {
    theme_parts$plot.title <- ttl$element
  }
  if (!is.null(sub$element)) {
    theme_parts$plot.subtitle <- sub$element
  }

  munch_theme <- if (length(theme_parts) > 0) {
    do.call(ggplot2::theme, theme_parts)
  }

  merged_theme <- if (!is.null(munch_theme) && !is.null(object$theme)) {
    munch_theme + object$theme
  } else {
    munch_theme %||% object$theme
  }

  pa_args <- list(
    caption = cap$sentinel,
    title = ttl$sentinel,
    subtitle = sub$sentinel,
    theme = merged_theme
  )

  if (!is.null(object$tag_levels)) {
    pa_args$tag_levels <- object$tag_levels
  }
  if (!is.null(object$tag_prefix)) {
    pa_args$tag_prefix <- object$tag_prefix
  }
  if (!is.null(object$tag_suffix)) {
    pa_args$tag_suffix <- object$tag_suffix
  }
  if (!is.null(object$tag_sep)) {
    pa_args$tag_sep <- object$tag_sep
  }

  plot + do.call(plot_annotation, pa_args)
}
