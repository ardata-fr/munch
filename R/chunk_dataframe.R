#' Apply default properties to chunks
#'
#' Fills NA values in chunk data with default properties.
#'
#' @param chunks A chunk data.frame (from flextable::chunk_dataframe).
#' @param text_props Text properties created with [default_text_props()].
#'   If `NULL`, uses current defaults.
#'
#' @return A chunk data.frame with NA values replaced.
#' @noRd
apply_defaults <- function(chunks, text_props = NULL) {
  if (is.null(text_props)) {
    text_props <- default_text_props()
  }

  na_replace <- function(x, default) {
    x[is.na(x)] <- default
    x
  }

  chunks$font.size <- na_replace(chunks$font.size, text_props$font.size)
  chunks$font.family <- na_replace(chunks$font.family, text_props$font.family)
  chunks$color <- na_replace(chunks$color, text_props$font.color)
  chunks$bold <- na_replace(chunks$bold, FALSE)
  chunks$italic <- na_replace(chunks$italic, FALSE)
  chunks$underlined <- na_replace(chunks$underlined, FALSE)
  chunks$strike <- na_replace(chunks$strike, FALSE)
  chunks$shading.color <- na_replace(chunks$shading.color, "transparent")
  chunks$vertical.align <- na_replace(chunks$vertical.align, "baseline")

  chunks
}

#' Split text chunks into word-level chunks
#'
#' Splits each text chunk at space boundaries so that
#' line wrapping can break between words. Non-text chunks
#' (images, newlines) pass through unchanged.
#'
#' @param chunks A chunk data.frame.
#' @return A chunk data.frame with finer granularity.
#' @noRd
split_chunks_into_words <- function(chunks) {
  if (nrow(chunks) == 0) {
    return(chunks)
  }

  result_list <- vector("list", nrow(chunks))

  for (i in seq_len(nrow(chunks))) {
    row <- chunks[i, , drop = FALSE]

    # Skip non-text chunks (images, newlines, single spaces)
    has_img <- ("img_data" %in% names(row) && !is.null(row$img_data[[1]])) ||
      ("img_path" %in% names(row) && !is.na(row$img_path))
    if (has_img || is.na(row$txt) || row$txt %in% c("\n", "\n\n", " ")) {
      result_list[[i]] <- row
      next
    }

    # Split text at space boundaries, keeping spaces
    # "foo bar baz" -> c("foo", " ", "bar", " ", "baz")
    parts <- strsplit(row$txt, "(?<= )|(?= )", perl = TRUE)[[1]]

    if (length(parts) <= 1) {
      result_list[[i]] <- row
      next
    }

    # Replicate the row for each part
    expanded <- row[rep(1L, length(parts)), , drop = FALSE]
    expanded$txt <- parts
    rownames(expanded) <- NULL
    result_list[[i]] <- expanded
  }

  result <- do.call(rbind, result_list)
  rownames(result) <- NULL
  class(result) <- c("chunk", "data.frame")
  result
}

#' Combine multiple chunk data.frames
#'
#' @param ... Chunk data.frames to combine.
#' @return A combined chunk data.frame.
#' @noRd
rbind_chunks <- function(...) {
  chunks_list <- list(...)
  chunks_list <- chunks_list[!sapply(chunks_list, is.null)]

  if (length(chunks_list) == 0) {
    return(flextable::chunk_dataframe())
  }

  # Get all column names across all chunks
  all_cols <- unique(unlist(lapply(chunks_list, names)))

  # Fill missing columns with NA
  chunks_list <- lapply(chunks_list, function(chunk) {
    missing_cols <- setdiff(all_cols, names(chunk))
    for (col in missing_cols) {
      chunk[[col]] <- NA
    }
    chunk[, all_cols, drop = FALSE]
  })

  result <- do.call(rbind, chunks_list)
  class(result) <- c("chunk", "data.frame")
  result
}
