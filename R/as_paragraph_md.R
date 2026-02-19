#' @title Convert Markdown to a Paragraph Object
#' @description
#' Converts a markdown string to a paragraph object compatible
#' with flextable. This allows using markdown syntax to format
#' text in flextable cells.
#'
#' @param x A character string containing markdown.
#' @param font_family_mono Font family to use for inline code.
#'   Defaults to `"mono"`.
#'
#' @return A paragraph object (class `"paragraph"`) that can be used
#'   with [flextable::mk_par()] or [flextable::as_flextable()].
#'
#' @details
#' Supported markdown syntax:
#' - `**bold**` or `__bold__`
#' - `*italic*` or `_italic_`
#' - `` `code` `` (monospace)
#' - `~~strikethrough~~`
#' - `[link](url)` (underlined and colored)
#' - `![alt](path)` (images)
#' - Line breaks with `\n\n` (paragraph) or two spaces + `\n` (hard break)
#'
#' @export
#' @family paragraph
#' @example inst/examples/as_paragraph_md.R
as_paragraph_md <- function(x, font_family_mono = "mono") {
  props <- default_text_props(code_font_family = font_family_mono)
  chunks <- md_to_chunks(x, text_props = props)
  # Add .chunk_index for flextable ordering
  chunks$.chunk_index <- seq_len(nrow(chunks))
  structure(list(chunks), class = "paragraph")
}
