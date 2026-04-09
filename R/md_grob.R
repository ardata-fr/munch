#' @title Create a Grob from Markdown Text
#' @description
#' Parses markdown text and creates a grid grob that can be
#' used in ggplot2 with `annotation_custom()` or directly with grid.
#' @param md_text Character string with markdown formatting.
#' @param x X position (0-1 in npc units, default 0.5).
#' @param y Y position (0-1 in npc units, default 0.5).
#' @param hjust Horizontal justification (0=left, 0.5=center, 1=right).
#' @param vjust Vertical justification (0=bottom, 0.5=center, 1=top).
#' @param width Maximum width in inches (NULL for no wrapping).
#' @param line_spacing Line height multiplier (default 1.2).
#' @param text_props Text properties created with [default_text_props()].
#'   If `NULL`, uses current defaults from [flextable::get_flextable_defaults()].
#'   Use `img_baseline_ratio` in text_props to control image vertical alignment.
#' @param name Grob name (optional).
#'
#' @return A grob of class "mdGrob".
#' @export
#' @example inst/examples/md_grob.R
md_grob <- function(
  md_text,
  x = 0.5,
  y = 0.5,
  hjust = 0.5,
  vjust = 0.5,
  width = NULL,
  line_spacing = 1.2,
  text_props = NULL,
  name = NULL
) {
  # Get text properties
  if (is.null(text_props)) {
    text_props <- default_text_props(line_spacing = line_spacing)
  } else if (!inherits(text_props, "text_props")) {
    cli::cli_abort(c(
      "{.arg text_props} must be created with {.fn default_text_props}.",
      "x" = "Got {.cls {class(text_props)}} instead."
    ))
  }

  # Use line_spacing from text_props if not explicitly provided
  if (missing(line_spacing) && !is.null(text_props$line_spacing)) {
    line_spacing <- text_props$line_spacing
  }

  # Parse markdown to chunks
  chunks <- md_to_chunks(md_text, text_props = text_props)

  # Split into words so that spaces become separate chunks.
  # This ensures correct positioning in all renderers (SVG
  # collapses leading/trailing whitespace in text elements).
  chunks <- split_chunks_into_words(chunks)

  # Get img_baseline_ratio from text_props
  img_baseline_ratio <- text_props$img_baseline_ratio %||% 0.15

  # Calculate metrics
  chunks <- calc_chunk_metrics(chunks, line_spacing, img_baseline_ratio)

  # Add chunk index
  chunks$.chunk_index <- seq_len(nrow(chunks))

  # Calculate dimensions for viewport
  lines <- arrange_chunks_into_lines(chunks, width)
  total_height <- sum(sapply(lines, function(l) l$height))
  total_width <- max(sapply(lines, function(l) l$width))

  # Create grob with properly sized viewport
  gr <- gTree(
    cl = "mdGrob",
    name = name,
    chunks = chunks,
    md_text = md_text,
    hjust = hjust,
    vjust = vjust,
    max_width = width,
    line_spacing = line_spacing,
    vp = viewport(
      x = unit(x, "npc"),
      y = unit(y, "npc"),
      width = unit(total_width, "inches"),
      height = unit(total_height, "inches"),
      just = c(hjust, vjust)
    )
  )

  gr
}

#' @export
#' @importFrom grid makeContent
makeContent.mdGrob <- function(x) {
  check_device_compatibility()

  chunks <- x$chunks
  hjust <- x$hjust
  vjust <- x$vjust
  max_width <- x$max_width
  line_spacing <- x$line_spacing

  if (nrow(chunks) == 0) {
    return(setChildren(x, gList(nullGrob())))
  }

  # Arrange chunks into lines
  lines <- arrange_chunks_into_lines(chunks, max_width)

  # Calculate total dimensions
  total_height <- sum(sapply(lines, function(l) l$height))
  total_width <- max(sapply(lines, function(l) l$width))

  # Container width for horizontal alignment
  container_w <- if (!is.null(max_width) && is.numeric(max_width) && max_width > 0) {
    max_width
  } else {
    total_width
  }

  # Create grobs for each line
  line_grobs <- list()
  current_y <- total_height # Start from top

  for (i in seq_along(lines)) {
    line <- lines[[i]]
    current_y <- current_y - line$height

    # Y position for this line
    line_y <- current_y + line$descent

    # Align line horizontally within the container
    current_x <- hjust * (container_w - line$width)
    for (j in seq_along(line$chunks)) {
      chunk <- line$chunks[[j]]

      # Render image chunks
      if (!is.null(chunk$img_path) && !is.na(chunk$img_path)) {
        img_raster <- read_image_raster(chunk$img_path)
        if (!is.null(img_raster)) {
          # Position image with its bottom at (line_y - descent)
          # This accounts for the image descent defined in metrics
          img_y <- line_y - chunk$descent

          img_grob <- rasterGrob(
            image = img_raster,
            x = unit(current_x, "inches"),
            y = unit(img_y, "inches"),
            width = unit(chunk$img_width, "inches"),
            height = unit(chunk$img_height, "inches"),
            hjust = 0,
            vjust = 0,
            interpolate = TRUE,
            name = paste0("img_", chunk$.chunk_index)
          )
          line_grobs <- c(line_grobs, list(img_grob))
        }
        current_x <- current_x + chunk$width
        next
      }

      if (is.na(chunk$txt) || chunk$txt == "" || isTRUE(chunk$is_newline)) {
        next
      }

      # Space-only chunks: advance position but don't create a
      # textGrob.  SVG renderers collapse leading/trailing
      # whitespace inside <text> elements, so we use the
      # measured width for positioning only.
      if (isTRUE(chunk$is_space)) {
        # Draw decorations (highlight, strikethrough, underline) for spaces
        if (
          !is.na(chunk$shading.color) &&
            chunk$shading.color != "transparent"
        ) {
          hl_ascend <- max(line$max_ascend, line$ascent)
          hl_descend <- max(line$max_descend, line$descent)
          rect_grob <- grid::rectGrob(
            x = unit(current_x, "inches"),
            y = unit(line_y - hl_descend, "inches"),
            width = unit(chunk$width, "inches"),
            height = unit(hl_ascend + hl_descend, "inches"),
            hjust = 0,
            vjust = 0,
            gp = gpar(
              fill = chunk$shading.color,
              col = NA,
              lwd = 0
            ),
            name = paste0("highlight_space_", chunk$.chunk_index)
          )
          line_grobs <- c(line_grobs, list(rect_grob))
        }
        if (isTRUE(chunk$strike)) {
          strike_y <- line_y + chunk$ascent * 0.35
          strike_grob <- grid::linesGrob(
            x = unit(c(current_x, current_x + chunk$width), "inches"),
            y = unit(c(strike_y, strike_y), "inches"),
            gp = gpar(
              col = chunk$color,
              lwd = chunk$font.size / 12
            ),
            name = paste0("strike_space_", chunk$.chunk_index)
          )
          line_grobs <- c(line_grobs, list(strike_grob))
        }
        if (isTRUE(chunk$underlined)) {
          underline_y <- line_y
          underline_grob <- grid::linesGrob(
            x = unit(c(current_x, current_x + chunk$width), "inches"),
            y = unit(c(underline_y, underline_y), "inches"),
            gp = gpar(
              col = chunk$color,
              lwd = chunk$font.size / 14
            ),
            name = paste0("underline_space_", chunk$.chunk_index)
          )
          line_grobs <- c(line_grobs, list(underline_grob))
        }
        current_x <- current_x + chunk$width
        next
      }

      # Calculate fontface
      fontface <- calc_fontface(chunk$bold, chunk$italic)

      # Use plain text label (no plotmath)
      label <- chunk$txt

      # Compute Y position based on vertical alignment
      text_y <- line_y
      if (identical(chunk$vertical.align, "superscript")) {
        text_y <- line_y + chunk$ascent * 0.4
      } else if (identical(chunk$vertical.align, "subscript")) {
        text_y <- line_y - chunk$descent * 0.2
      }

      # Create text grob
      txt_grob <- textGrob(
        label = label,
        x = unit(current_x, "inches"),
        y = unit(text_y, "inches"),
        hjust = 0,
        vjust = 0,
        gp = gpar(
          col = chunk$color,
          fontfamily = chunk$font.family,
          fontsize = chunk$font.size,
          fontface = fontface,
          lineheight = line_spacing
        ),
        name = paste0("chunk_", chunk$.chunk_index)
      )



      # Add highlight rect if needed
      # Use max glyph extents from systemfonts so the highlight covers
      # the full visual height of glyphs as rendered by ragg/systemfonts.
      if (
        !is.na(chunk$shading.color) &&
          chunk$shading.color != "transparent"
      ) {
        hl_ascend <- max(line$max_ascend, line$ascent)
        hl_descend <- max(line$max_descend, line$descent)
        rect_grob <- grid::rectGrob(
          x = unit(current_x, "inches"),
          y = unit(line_y - hl_descend, "inches"),
          width = unit(chunk$width, "inches"),
          height = unit(hl_ascend + hl_descend, "inches"),
          hjust = 0,
          vjust = 0,
          gp = gpar(
            fill = chunk$shading.color,
            col = NA,
            lwd = 0
          ),
          name = paste0("highlight_", chunk$.chunk_index)
        )
        line_grobs <- c(line_grobs, list(rect_grob))
      }

      line_grobs <- c(line_grobs, list(txt_grob))

      # Add strikethrough line if needed
      if (isTRUE(chunk$strike)) {
        strike_y <- line_y + chunk$ascent * 0.35
        strike_grob <- grid::linesGrob(
          x = unit(c(current_x, current_x + chunk$width), "inches"),
          y = unit(c(strike_y, strike_y), "inches"),
          gp = gpar(
            col = chunk$color,
            lwd = chunk$font.size / 12
          ),
          name = paste0("strike_", chunk$.chunk_index)
        )
        line_grobs <- c(line_grobs, list(strike_grob))
      }

      # Add underline if needed
      if (isTRUE(chunk$underlined)) {
        underline_y <- line_y
        underline_grob <- grid::linesGrob(
          x = unit(c(current_x, current_x + chunk$width), "inches"),
          y = unit(c(underline_y, underline_y), "inches"),
          gp = gpar(
            col = chunk$color,
            lwd = chunk$font.size / 14
          ),
          name = paste0("underline_", chunk$.chunk_index)
        )
        line_grobs <- c(line_grobs, list(underline_grob))
      }

      current_x <- current_x + chunk$width
    }
  }

  if (length(line_grobs) == 0) {
    line_grobs <- list(nullGrob())
  }

  setChildren(x, do.call(gList, line_grobs))
}

#' Arrange chunks into lines
#'
#' @param chunks Chunks data.frame with metrics.
#' @param max_width Maximum line width in inches (NULL for no wrapping).
#'
#' @return List of lines, each with chunks, width, height, ascent, descent.
#' @noRd
arrange_chunks_into_lines <- function(chunks, max_width = NULL) {
  lines <- list()
  current_line <- list(
    chunks = list(),
    width = 0,
    height = 0,
    ascent = 0,
    descent = 0,
    max_ascend = 0,
    max_descend = 0
  )

  for (i in seq_len(nrow(chunks))) {
    chunk <- as.list(chunks[i, ])

    # Check for newline
    if (isTRUE(chunk$is_newline)) {
      # Finish current line
      if (length(current_line$chunks) > 0 || length(lines) == 0) {
        if (current_line$height == 0) {
          # Empty line - use chunk height
          current_line$height <- chunk$height
          current_line$ascent <- chunk$ascent
          current_line$descent <- chunk$descent
          current_line$max_ascend <- chunk$max_ascend
          current_line$max_descend <- chunk$max_descend
        }
        lines <- c(lines, list(current_line))
      }
      # Start new line
      current_line <- list(
        chunks = list(),
        width = 0,
        height = 0,
        ascent = 0,
        descent = 0
      )
      next
    }

    # Check for wrapping
    if (!is.null(max_width) && max_width > 0) {
      if (
        current_line$width + chunk$width > max_width &&
          length(current_line$chunks) > 0
      ) {
        # Wrap to new line
        lines <- c(lines, list(current_line))
        current_line <- list(
          chunks = list(),
          width = 0,
          height = 0,
          ascent = 0,
          descent = 0
        )
        # Skip leading spaces on new line
        if (isTRUE(chunk$is_space)) {
          next
        }
      }
    }

    # Add chunk to current line
    current_line$chunks <- c(current_line$chunks, list(chunk))
    current_line$width <- current_line$width + chunk$width
    current_line$ascent <- max(current_line$ascent, chunk$ascent)
    current_line$descent <- max(current_line$descent, chunk$descent)
    current_line$height <- current_line$ascent + current_line$descent
    current_line$max_ascend <- max(current_line$max_ascend, chunk$max_ascend)
    current_line$max_descend <- max(current_line$max_descend, chunk$max_descend)
  }

  # Don't forget the last line
  if (length(current_line$chunks) > 0) {
    lines <- c(lines, list(current_line))
  }

  # Handle empty input
  if (length(lines) == 0) {
    lines <- list(list(
      chunks = list(),
      width = 0,
      height = 0.2,
      ascent = 0.15,
      descent = 0.05
    ))
  }

  lines
}

#' @title Get Dimensions of a mdGrob
#' @description
#' Returns the dimensions of an mdGrob object.
#' @param x A mdGrob object.
#'
#' @return A list with width and height in inches.
#' @export
#' @method dim mdGrob
#' @keywords internal
dim.mdGrob <- function(x) {
  chunks <- x$chunks
  max_width <- x$max_width

  if (nrow(chunks) == 0) {
    return(list(width = 0, height = 0))
  }

  lines <- arrange_chunks_into_lines(chunks, max_width)

  list(
    width = max(sapply(lines, function(l) l$width)),
    height = sum(sapply(lines, function(l) l$height))
  )
}

#' @export
widthDetails.mdGrob <- function(x) {
  dims <- dim(x)
  unit(dims$width, "inches")
}

#' @export
heightDetails.mdGrob <- function(x) {
  dims <- dim(x)
  unit(dims$height, "inches")
}

#' @title Print Method for mdGrob
#' @description
#' Prints summary information for an mdGrob object.
#' @param x A mdGrob object.
#' @param ... Additional arguments (ignored).
#' @return A grid grob object of class "mdGrob" representing rich text content (invisibly).
#' @export
#' @method print mdGrob
#' @keywords internal
print.mdGrob <- function(x, ...) {
  dims <- dim(x)
  cat("mdGrob\n")
  cat(
    "  Text:",
    substr(x$md_text, 1, 50),
    if (nchar(x$md_text) > 50) "..." else "",
    "\n"
  )
  cat("  Chunks:", nrow(x$chunks), "\n")
  cat(
    "  Dimensions:",
    round(dims$width, 3),
    "x",
    round(dims$height, 3),
    "inches\n"
  )
  invisible(x)
}

#' @title Plot a mdGrob
#' @description
#' Draws an mdGrob object to the current graphics device.
#' @param x A mdGrob object.
#' @param ... Additional arguments (ignored).
#' @return A grid grob object of class "mdGrob" representing rich text content (invisibly).
#' @export
#' @method plot mdGrob
#' @importFrom grid grid.newpage grid.draw pushViewport popViewport
#' @keywords internal
plot.mdGrob <- function(x, ...) {
  grid.newpage()
  pushViewport(viewport(
    width = unit(1, "npc") - unit(10, "pt"),
    height = unit(1, "npc") - unit(10, "pt")
  ))
  grid.draw(x)
  popViewport()
  invisible(x)
}

#' @title Create a Grob from flextable Chunks
#' @description
#' Creates a grob directly from flextable chunk data.frames
#' (created with [flextable::as_paragraph()]), bypassing markdown parsing.
#' @param chunks A chunk data.frame from flextable (e.g., from
#'   [flextable::as_paragraph()]).
#' @param x X position (0-1 in npc units).
#' @param y Y position (0-1 in npc units).
#' @param hjust Horizontal justification.
#' @param vjust Vertical justification.
#' @param width Maximum width in inches (NULL for no wrapping).
#' @param line_spacing Line height multiplier.
#' @param img_baseline_ratio Controls vertical alignment of inline images.
#'   Specifies the proportion of the image height below the text baseline:
#'   `0` = bottom at baseline, `0.15` = default, `0.35` = centered on text,
#'   `0.5` = centered on baseline.
#' @param name Grob name.
#'
#' @return A grob of class "mdGrob".
#' @export
#' @examples
#' #
#' @examplesIf require(ggiraph, quietly = TRUE)
#' library(grid)
#' library(flextable)
#' library(ggiraph)
#'
#' library(gdtools)
#' font_set_liberation()
#' flextable::set_flextable_defaults(
#'   font.size = 12,
#'   font.family = "Liberation Sans"
#' )
#'
#' chunks <- as_paragraph(
#'   as_chunk("E = mc"),
#'   as_sup("2")
#' )
#' gr <- chunks_grob(chunks)
#'
#' x <- girafe(
#'   width_svg = 1,
#'   height_svg = 1,
#'   bg = "wheat",
#'   options = list(opts_sizing(rescale = FALSE)),
#'   code = {
#'     grid.newpage()
#'     grid.draw(gr)
#'   },
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#'
#' x
#'
#' init_flextable_defaults()
chunks_grob <- function(
  chunks,
  x = 0.5,
  y = 0.5,
  hjust = 0.5,
  vjust = 0.5,
  width = NULL,
  line_spacing = 1.2,
  img_baseline_ratio = 0.15,
  name = NULL
) {
  # Handle paragraph class from flextable (list of chunk data.frames)
  if (inherits(chunks, "paragraph")) {
    chunks <- chunks[[1]]
  }

  # Apply defaults to fill NA values
  chunks <- apply_defaults(chunks)

  # Split into words so that spaces become separate chunks.
  # This ensures correct positioning in all renderers (SVG
  # collapses leading/trailing whitespace in text elements).
  chunks <- split_chunks_into_words(chunks)

  # Calculate metrics
  chunks <- calc_chunk_metrics(chunks, line_spacing, img_baseline_ratio)

  # Add chunk index
  chunks$.chunk_index <- seq_len(nrow(chunks))

  # Calculate dimensions for viewport
  lines <- arrange_chunks_into_lines(chunks, width)
  total_height <- sum(sapply(lines, function(l) l$height))
  total_width <- max(sapply(lines, function(l) l$width))

  # Create grob with properly sized viewport
  gr <- gTree(
    cl = "mdGrob",
    name = name,
    chunks = chunks,
    md_text = paste(chunks$txt[!is.na(chunks$txt)], collapse = ""),
    hjust = hjust,
    vjust = vjust,
    max_width = width,
    line_spacing = line_spacing,
    vp = viewport(
      x = unit(x, "npc"),
      y = unit(y, "npc"),
      width = unit(total_width, "inches"),
      height = unit(total_height, "inches"),
      just = c(hjust, vjust)
    )
  )

  gr
}
