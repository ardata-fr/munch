#' @title Default Text Properties for Markdown Grobs
#' @description
#' Returns a list of text properties used for rendering markdown text.
#' Default values are taken from [flextable::get_flextable_defaults()],
#' allowing integration with flextable's theming system while providing
#' a standalone API for munch.
#'
#' @param font_size Font size in points.
#' @param font_family Font family name for regular text.
#' @param font_color Text color.
#' @param code_font_family Font family name for inline code (backticks).
#'   Defaults to `"mono"`.
#' @param line_spacing Line height multiplier.
#' @param img_baseline_ratio Controls vertical alignment of inline images.
#'   Specifies the proportion of the image height that appears below the
#'   text baseline:
#'   - `0`: image bottom at baseline
#'   - `0.15`: (default) similar to text descent proportions
#'   - `0.35`: image centered on text vertical center
#'   - `0.5`: image centered on baseline
#' @param bold,italic If `TRUE`, the text is bold or italic by default;
#'   markdown emphasis adds to it. Default `FALSE`.
#'
#' @return A list of class `"text_props"` with elements:
#'   - `font.size`: Font size in points
#'   - `font.family`: Font family name
#'   - `font.color`: Text color
#'   - `code.font.family`: Font family for code
#'   - `line_spacing`: Line height multiplier
#'   - `img_baseline_ratio`: Image baseline alignment ratio
#'   - `bold`, `italic`: default font face of the text
#'
#' Some element names use dot separators (`font.size`, `font.family`, etc.)
#' for compatibility with 'flextable' conventions. Function parameters
#' and newer elements use snake_case (`line_spacing`, `img_baseline_ratio`)
#' which is the preferred convention going forward.
#'
#' @details
#' When arguments are `NULL` (the default), values are inherited from
#' [flextable::get_flextable_defaults()]. This allows users to either:
#'
#' 1. Use munch independently by specifying all properties:
#'    ```r
#'    props <- default_text_props(font_size = 12, font_family = "serif")
#'    md_grob("**bold**", text_props = props)
#'    ```
#'
#' 2. Use flextable's theming system:
#'    ```r
#'    flextable::set_flextable_defaults(font.size = 14)
#'    md_grob("**bold**")
#'    ```
#'
#' @export
#' @example inst/examples/default_text_props.R
default_text_props <- function(
  font_size = NULL,
  font_family = NULL,
  font_color = NULL,
  code_font_family = NULL,
  line_spacing = NULL,
  img_baseline_ratio = NULL,
  bold = NULL,
  italic = NULL
) {
  # Get flextable defaults as base
  ft_defaults <- flextable::get_flextable_defaults()

  props <- list(
    font.size = font_size %||% ft_defaults$font.size,
    font.family = font_family %||% ft_defaults$font.family,
    font.color = font_color %||% ft_defaults$font.color,
    code.font.family = code_font_family %||% "mono",
    line_spacing = line_spacing %||% 1.2,
    img_baseline_ratio = img_baseline_ratio %||% 0.15,
    bold = isTRUE(bold),
    italic = isTRUE(italic)
  )

  class(props) <- c("text_props", "list")
  props
}

#' @export
print.text_props <- function(x, ...) {
  cli::cli_h3("Text properties")
  cli::cli_ul(c(
    "font_size: {.val {x$font.size}}",
    "font_family: {.val {x$font.family}}",
    "font_color: {.val {x$font.color}}",
    "code_font_family: {.val {x$code.font.family}}",
    "line_spacing: {.val {x$line_spacing}}",
    "img_baseline_ratio: {.val {x$img_baseline_ratio}}",
    "bold: {.val {isTRUE(x$bold)}}",
    "italic: {.val {isTRUE(x$italic)}}"
  ))
  invisible(x)
}
