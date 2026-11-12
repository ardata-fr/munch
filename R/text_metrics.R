#' Calculate text metrics for chunks
#'
#' Computes width, height, ascent and descent for each text chunk
#' using gdtools for accurate font metrics.
#'
#' @param chunks A md_chunk data.frame.
#' @param line_spacing Line spacing, a multiple of the single line spacing
#'   of the font (default 1).
#' @param img_baseline_ratio Proportion of image height below baseline (default 0.15).
#'
#' @return The chunks data.frame with added columns: width, height, ascent, descent.
#' @noRd
#' @importFrom gdtools strings_sizes
#' @importFrom systemfonts font_info
calc_chunk_metrics <- function(
  chunks,
  line_spacing = 1,
  img_baseline_ratio = 0.15
) {
  if (nrow(chunks) == 0) {
    chunks$width <- numeric(0)
    chunks$height <- numeric(0)
    chunks$ascent <- numeric(0)
    chunks$descent <- numeric(0)
    chunks$max_ascend <- numeric(0)
    chunks$max_descend <- numeric(0)
    chunks$is_newline <- logical(0)
    chunks$is_space <- logical(0)
    return(chunks)
  }

  # Normalize image columns from different sources

  # flextable::as_image() uses img_data (a list column), while md_to_chunks() uses img_path
  # Consolidate to img_path for uniform handling
  if (!is.null(chunks$img_data)) {
    # img_data is a list column - extract character values
    img_data_paths <- vapply(
      chunks$img_data,
      function(x) {
        if (is.null(x) || length(x) == 0) NA_character_ else as.character(x[1])
      },
      character(1)
    )

    if (is.null(chunks$img_path)) {
      chunks$img_path <- img_data_paths
    } else {
      # Fill img_path from img_data where img_path is NA
      na_path <- is.na(chunks$img_path)
      chunks$img_path[na_path] <- img_data_paths[na_path]
    }
  }
  if (is.null(chunks$img_path)) {
    chunks$img_path <- NA_character_
  }

  # flextable::as_image() uses width/height, while md_to_chunks() uses img_width/img_height
  # Consolidate to img_width/img_height
  if (!is.null(chunks$width) && is.null(chunks$img_width)) {
    chunks$img_width <- chunks$width
  } else if (!is.null(chunks$width) && !is.null(chunks$img_width)) {
    na_w <- is.na(chunks$img_width)
    chunks$img_width[na_w] <- chunks$width[na_w]
  }
  if (!is.null(chunks$height) && is.null(chunks$img_height)) {
    chunks$img_height <- chunks$height
  } else if (!is.null(chunks$height) && !is.null(chunks$img_height)) {
    na_h <- is.na(chunks$img_height)
    chunks$img_height[na_h] <- chunks$height[na_h]
  }

  if (is.null(chunks$img_width)) {
    chunks$img_width <- NA_real_
  }
  if (is.null(chunks$img_height)) {
    chunks$img_height <- NA_real_
  }

  # Initialize metric columns
  chunks$width <- 0
  chunks$height <- 0
  chunks$ascent <- 0
  chunks$descent <- 0
  chunks$max_ascend <- 0
  chunks$max_descend <- 0

  # Mark special chunks
  chunks$is_newline <- !is.na(chunks$txt) & chunks$txt %in% c("\n", "\n\n")
  chunks$is_space <- !is.na(chunks$txt) & chunks$txt == " "

  # Separate image vs text chunks
  is_img <- !is.na(chunks$img_path)
  is_text <- !is_img

  # --- Text metrics ---
  if (any(is_text)) {
    txt_measure <- chunks$txt[is_text]
    txt_measure[chunks$is_newline[is_text]] <- "."
    txt_measure[is.na(txt_measure)] <- ""

    # widths with the kerning of the fonts, as devices draw the words
    metrics <- gdtools::strings_sizes(
      x = txt_measure,
      fontname = chunks$font.family[is_text],
      fontsize = chunks$font.size[is_text],
      bold = chunks$bold[is_text],
      italic = chunks$italic[is_text],
      kerning = TRUE
    )

    chunks$width[is_text] <- metrics$width

    # Line metrics of the font, as Word uses them for single line spacing
    # (gdtools::font_line_metrics()), so that all lines of a block have the
    # same height and a line spacing of 1 gives the distance between lines
    # of Word. As in Word, the space added by a line spacing larger than 1 is
    # below the line: the part above the baseline does not change.
    ref_metrics <- gdtools::font_line_metrics(
      fontname = chunks$font.family[is_text],
      fontsize = chunks$font.size[is_text],
      bold = chunks$bold[is_text],
      italic = chunks$italic[is_text]
    )

    chunks$ascent[is_text] <- ref_metrics$ascent
    chunks$descent[is_text] <- pmax(
      ref_metrics$descent + (line_spacing - 1) * ref_metrics$line_height,
      0
    )
    chunks$height[is_text] <- (chunks$ascent[is_text] + chunks$descent[is_text])

    # Font-level max glyph extents from systemfonts (used for highlight rects).
    # gdtools/Cairo ascent can be smaller than the actual glyph extent that
    # ragg/systemfonts renderers use, so highlights need these bounds.
    fi <- systemfonts::font_info(
      family = chunks$font.family[is_text],
      size = chunks$font.size[is_text]
    )
    chunks$max_ascend[is_text] <- fi$max_ascend / 72
    chunks$max_descend[is_text] <- abs(fi$max_descend) / 72

    # Adjust for superscript/subscript
    is_ss <- is_text &
      (chunks$vertical.align %in% c("superscript", "subscript"))
    chunks$width[is_ss] <- chunks$width[is_ss] * 0.75
    chunks$font.size[is_ss] <- chunks$font.size[is_ss] * 0.75
  }

  # --- Image metrics ---
  if (any(is_img)) {
    for (idx in which(is_img)) {
      img_info <- get_image_info(chunks$img_path[idx])

      if (is.null(img_info)) {
        # Image unreadable: zero-size placeholder
        chunks$width[idx] <- 0
        chunks$height[idx] <- 0
        chunks$ascent[idx] <- 0
        chunks$descent[idx] <- 0
        next
      }

      aspect <- img_info$width / img_info$height
      target_h <- chunks$img_height[idx]
      target_w <- chunks$img_width[idx]

      if (is.na(target_h) && is.na(target_w)) {
        # Default: image height = 2x font size in inches
        target_h <- chunks$font.size[idx] / 72 * 2
        target_w <- target_h * aspect
      } else if (is.na(target_w)) {
        target_w <- target_h * aspect
      } else if (is.na(target_h)) {
        target_h <- target_w / aspect
      }

      chunks$img_width[idx] <- target_w
      chunks$img_height[idx] <- target_h
      chunks$width[idx] <- target_w
      chunks$height[idx] <- target_h
      # Split image height into ascent/descent based on img_baseline_ratio
      # This controls how much of the image appears below the text baseline
      chunks$ascent[idx] <- target_h * (1 - img_baseline_ratio)
      chunks$descent[idx] <- target_h * img_baseline_ratio
    }
  }

  chunks
}

#' Calculate fontface integer from bold/italic
#'
#' @param bold Logical.
#' @param italic Logical.
#' @return Integer fontface (1=plain, 2=bold, 3=italic, 4=bolditalic).
#' @noRd
calc_fontface <- function(bold, italic) {
  bold <- isTRUE(bold)
  italic <- isTRUE(italic)

  if (bold && italic) {
    4L
  } else if (bold) {
    2L
  } else if (italic) {
    3L
  } else {
    1L
  }
}
