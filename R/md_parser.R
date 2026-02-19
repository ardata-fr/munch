#' @title Parse Markdown Text to Chunks
#' @description
#' Converts markdown text to a chunk data.frame using commonmark.
#' Supports: bold (**), italic (*), code (`), strikethrough (~~),
#' images, and line breaks.
#'
#' @param md_text Character string with markdown formatting.
#' @param text_props Text properties created with [default_text_props()].
#'   If `NULL`, uses current defaults from [flextable::get_flextable_defaults()].
#'
#' @return A chunk data.frame. (class "chunk").
#' @noRd
#' @importFrom flextable chunk_dataframe get_flextable_defaults
#' @examples
#' md_to_chunks("This is **bold** and *italic* text.")
#' md_to_chunks("Code: `print(x)`")
#'
#' # With custom text properties
#' props <- default_text_props(font_size = 14)
#' md_to_chunks("**Large text**", text_props = props)
md_to_chunks <- function(md_text, text_props = NULL) {
  # Get text properties
  if (is.null(text_props)) {
    text_props <- default_text_props()
  }

  # Create props list with text formatting defaults
  defaults <- list(
    font.size = text_props$font.size,
    font.family = text_props$font.family,
    font.color = text_props$font.color,
    code.font.family = text_props$code.font.family,
    bold = FALSE,
    italic = FALSE,
    underlined = FALSE,
    strike = FALSE,
    shading.color = NA_character_,
    vertical.align = "baseline"
  )

  # Parse markdown to XML
  xml_str <- commonmark::markdown_xml(md_text, extensions = TRUE)
  doc <- xml2::read_xml(xml_str)

  # Get namespace
  ns <- xml2::xml_ns(doc)

  # Find all paragraph nodes
  paragraphs <- xml2::xml_find_all(doc, ".//d1:paragraph", ns)

  if (length(paragraphs) == 0) {
    return(apply_defaults(
      chunk_dataframe(txt = md_text),
      text_props = text_props
    ))
  }

  # Parse each paragraph
  all_chunks <- lapply(seq_along(paragraphs), function(i) {
    p <- paragraphs[[i]]
    chunks <- parse_md_node(p, defaults, ns)

    # Add paragraph break between paragraphs (except last)
    if (i < length(paragraphs) && nrow(chunks) > 0) {
      para_break <- chunk_dataframe(txt = "\n\n")
      chunks <- rbind_chunks(chunks, para_break)
    }

    chunks
  })

  result <- do.call(rbind_chunks, all_chunks)
  apply_defaults(result, text_props = text_props)
}

#' Parse a markdown XML node recursively
#'
#' @param node XML node.
#' @param props Current text properties (from get_flextable_defaults).
#' @param ns XML namespace.
#'
#' @return A chunk data.frame.
#' @noRd
parse_md_node <- function(node, props, ns) {
  name <- xml2::xml_name(node)
  children <- xml2::xml_children(node)

  # Update properties based on node type
  new_props <- props

  if (name == "strong") {
    new_props$bold <- TRUE
  } else if (name == "emph") {
    new_props$italic <- TRUE
  } else if (name == "code") {
    new_props$font.family <- props$code.font.family %||% "mono"
  } else if (name == "strikethrough") {
    new_props$strike <- TRUE
  } else if (name == "link") {
    new_props$font.color <- "#0066cc"
    new_props$underlined <- TRUE
  }

  # Handle terminal nodes
  if (name == "text") {
    txt <- xml2::xml_text(node)
    return(chunk_dataframe(
      txt = txt,
      font.size = new_props$font.size,
      bold = new_props$bold,
      italic = new_props$italic,
      underlined = new_props$underlined,
      strike = new_props$strike,
      color = new_props$font.color,
      shading.color = new_props$shading.color,
      font.family = new_props$font.family,
      vertical.align = new_props$vertical.align
    ))
  }

  if (name == "softbreak") {
    return(chunk_dataframe(txt = " "))
  }

  if (name == "linebreak") {
    return(chunk_dataframe(txt = "\n"))
  }

  if (name == "code") {
    txt <- xml2::xml_text(node)
    return(chunk_dataframe(
      txt = txt,
      font.size = new_props$font.size,
      bold = FALSE,
      italic = FALSE,
      underlined = FALSE,
      color = new_props$font.color,
      shading.color = new_props$shading.color,
      font.family = new_props$font.family,
      vertical.align = "baseline"
    ))
  }

  if (name == "image") {
    dest <- xml2::xml_attr(node, "destination")
    chunk <- chunk_dataframe(
      txt = NA_character_,
      font.size = new_props$font.size
    )
    chunk$img_path <- dest
    return(chunk)
  }

  # For nodes with children, recurse
  if (length(children) > 0) {
    child_chunks <- lapply(children, parse_md_node, props = new_props, ns = ns)
    return(do.call(rbind_chunks, child_chunks))
  }

  # Empty node
  NULL
}

#' Parse inline markdown elements
#'
#' A simpler regex-based parser for common inline markdown.
#' Use this when you don't need full commonmark parsing.
#'
#' @param text Character string with markdown.
#'
#' @return A chunk data.frame.
#' @noRd
#' @examples
#' parse_inline_md("Hello **world**!")
parse_inline_md <- function(text) {
  defaults <- get_flextable_defaults()

  # Patterns for inline markdown
  patterns <- list(
    bold_italic = "\\*\\*\\*(.+?)\\*\\*\\*",
    bold = "\\*\\*(.+?)\\*\\*",
    italic = "\\*(.+?)\\*",
    code = "`(.+?)`",
    strikethrough = "~~(.+?)~~"
  )

  # Simple tokenizer approach
  chunks <- list()
  remaining <- text
  chunk_idx <- 1

  while (nchar(remaining) > 0) {
    # Find first match among all patterns
    first_match <- NULL
    first_pos <- nchar(remaining) + 1
    match_type <- NULL

    for (pname in names(patterns)) {
      m <- regexpr(patterns[[pname]], remaining, perl = TRUE)
      if (m > 0 && m < first_pos) {
        first_pos <- m
        first_match <- regmatches(remaining, m)
        match_type <- pname
      }
    }

    if (is.null(first_match)) {
      # No more matches, add remaining text
      if (nchar(remaining) > 0) {
        chunks[[chunk_idx]] <- chunk_dataframe(
          txt = remaining,
          font.size = defaults$font.size,
          font.family = defaults$font.family,
          color = defaults$font.color,
          bold = FALSE,
          italic = FALSE
        )
      }
      break
    }

    # Add text before match
    if (first_pos > 1) {
      before_text <- substr(remaining, 1, first_pos - 1)
      chunks[[chunk_idx]] <- chunk_dataframe(
        txt = before_text,
        font.size = defaults$font.size,
        font.family = defaults$font.family,
        color = defaults$font.color,
        bold = FALSE,
        italic = FALSE
      )
      chunk_idx <- chunk_idx + 1
    }

    # Extract content from match
    inner_text <- gsub(patterns[[match_type]], "\\1", first_match, perl = TRUE)

    # Create chunk with appropriate formatting
    chunk_bold <- FALSE
    chunk_italic <- FALSE
    chunk_strike <- FALSE
    chunk_family <- defaults$font.family
    chunk_shading <- NA_character_
    chunk_color <- defaults$font.color

    if (match_type == "bold_italic") {
      chunk_bold <- TRUE
      chunk_italic <- TRUE
    } else if (match_type == "bold") {
      chunk_bold <- TRUE
    } else if (match_type == "italic") {
      chunk_italic <- TRUE
    } else if (match_type == "code") {
      chunk_family <- "mono"
    } else if (match_type == "strikethrough") {
      chunk_strike <- TRUE
    }

    chunks[[chunk_idx]] <- chunk_dataframe(
      txt = inner_text,
      font.size = defaults$font.size,
      font.family = chunk_family,
      color = chunk_color,
      bold = chunk_bold,
      italic = chunk_italic,
      strike = chunk_strike,
      shading.color = chunk_shading
    )
    chunk_idx <- chunk_idx + 1

    # Update remaining text
    match_end <- first_pos + nchar(first_match) - 1
    remaining <- substr(remaining, match_end + 1, nchar(remaining))
  }

  if (length(chunks) == 0) {
    return(apply_defaults(chunk_dataframe(txt = text)))
  }

  result <- do.call(rbind_chunks, chunks)
  apply_defaults(result)
}
