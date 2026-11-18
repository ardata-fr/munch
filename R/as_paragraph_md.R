#' @title Convert Markdown to a Paragraph Object
#' @description
#' Converts markdown strings to a paragraph object compatible
#' with flextable. This allows using markdown syntax to format
#' text in flextable cells.
#'
#' As [flextable::as_paragraph()], it is vectorised: each element of `x`
#' gives the paragraph of a row, so that a column of markdown can be used
#' with [flextable::mk_par()] (`value = as_paragraph_md(col)`).
#'
#' @param x A character vector of markdown, one element per paragraph.
#' @param font_family_mono Font family to use for inline code.
#'   Defaults to `"mono"`.
#'
#' @return A paragraph object (class `"paragraph"`), with one paragraph per
#'   element of `x`, that can be used with [flextable::mk_par()] or
#'   [flextable::as_flextable()].
#'
#' @details
#' Supported markdown syntax:
#' - `**bold**` or `__bold__`
#' - `*italic*` or `_italic_`
#' - `` `code` `` (monospace)
#' - `~~strikethrough~~`
#' - `[link](url)` (underlined and colored)
#' - `![alt](path)` (images, with a height of twice the font size, as in
#'   [md_grob()]; an image that can not be read is dropped with a warning)
#' - Line breaks with `\n\n` (paragraph) or two spaces + `\n` (hard break)
#' - `^superscript^` and `~subscript~`, as in Pandoc (no space inside, unless
#'   escaped: `^a\ b^`)
#' - Equations `$...$` and `$$...$$` (LaTeX), as in Pandoc; `\$` is a
#'   dollar. They are written as equations of 'flextable'
#'   ([flextable::as_equation()]), which needs the package 'equatags'.
#'
#' @export
#' @family paragraph
#' @example inst/examples/as_paragraph_md.R
as_paragraph_md <- function(x, font_family_mono = "mono") {
  props <- default_text_props(code_font_family = font_family_mono)
  x <- as.character(x)
  x[is.na(x)] <- ""
  paragraphs <- lapply(x, function(text) {
    chunks <- md_to_chunks(text, text_props = props)
    # flextable chooses the style of equations itself (display when they
    # are alone in their paragraph) and refuses unknown columns
    chunks$eq_display <- NULL
    chunks <- images_for_flextable(chunks)
    # Add .chunk_index for flextable ordering
    chunks$.chunk_index <- seq_len(nrow(chunks))
    chunks
  })
  structure(paragraphs, class = "paragraph")
}

# Images of markdown as flextable wants them: the file in `img_data`, with
# its size in `width` and `height` (as flextable::as_image() does), and no
# column `img_path`, which flextable refuses. The size is the default size
# of images in munch (default_image_size()). An image that can not be read
# is dropped (get_image_info() warns).
images_for_flextable <- function(chunks) {
  if (is.null(chunks$img_path)) {
    return(chunks)
  }
  is_img <- which(!is.na(chunks$img_path))
  drop <- integer(0)
  for (k in is_img) {
    info <- get_image_info(chunks$img_path[k])
    if (is.null(info)) {
      drop <- c(drop, k)
      next
    }
    size <- default_image_size(info, chunks$font.size[k])
    chunks$width[k] <- size$width
    chunks$height[k] <- size$height
    chunks$img_data[k] <- list(chunks$img_path[k])
  }
  chunks$img_path <- NULL
  if (length(drop) > 0) {
    chunks <- chunks[-drop, , drop = FALSE]
    rownames(chunks) <- NULL
  }
  chunks
}
