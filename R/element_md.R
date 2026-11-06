#' @title Markdown Theme Element for ggplot2
#' @description
#' A theme element that renders text labels as markdown.
#' Use in place of [ggplot2::element_text()] for plot titles,
#' subtitles, captions, axis labels, etc.
#'
#' @param family Font family.
#' @param code_font_family Font family for inline code. Defaults to `"mono"`.
#' @param face Font face ("plain", "bold", "italic", "bold.italic").
#' @param colour,color Text color.
#' @param size Font size in points.
#' @param hjust Horizontal justification (0-1).
#' @param vjust Vertical justification (0-1).
#' @param angle Text rotation angle in degrees.
#' @param lineheight Line height multiplier.
#' @param margin Margins around the text (use [ggplot2::margin()]).
#' @param debug Show debug rectangles.
#' @param inherit.blank Should this element inherit blank elements.
#'
#' @return An element of class `c("element_md", "element_text", "element")`.
#' @export
#' @examplesIf require("ggiraph", quietly = TRUE, character.only = TRUE)
#' library(ggplot2)
#'
#' library(gdtools)
#' font_set_liberation()
#' flextable::set_flextable_defaults(
#'   font.size = 12,
#'   font.family = "Liberation Sans"
#' )
#'
#' p1 <- ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   labs(title = "**Bold title** with *italic*") +
#'   theme(plot.title = element_md())
#'
#' girafe(
#'   ggobj = p1,
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#'
#' p2 <- ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   labs(
#'     title = "**MPG** vs *Weight*",
#'     caption = "Source: `mtcars` dataset"
#'   ) +
#'   theme(
#'     plot.title = element_md(size = 16),
#'     plot.caption = element_md(size = 9)
#'   )
#' girafe(
#'   ggobj = p2,
#'   check_fonts_dependencies = TRUE
#' )
element_md <- function(
  family = NULL,
  code_font_family = NULL,
  face = NULL,
  colour = NULL,
  size = NULL,
  hjust = NULL,
  vjust = NULL,
  angle = NULL,
  lineheight = NULL,
  color = NULL,
  margin = NULL,
  debug = FALSE,
  inherit.blank = FALSE
) {
  if (!is.null(color)) {
    colour <- color
  }
  structure(
    list(
      family = family,
      code_font_family = code_font_family,
      face = face,
      colour = colour,
      size = size,
      hjust = hjust,
      vjust = vjust,
      angle = angle,
      lineheight = lineheight,
      margin = margin,
      debug = debug,
      inherit.blank = inherit.blank
    ),
    class = c("element_md", "element_text", "element")
  )
}

#' @importFrom ggplot2 element_grob
#' @export
element_grob.element_md <- function(
  element,
  label = "",
  x = NULL,
  y = NULL,
  family = NULL,
  face = NULL,
  colour = NULL,
  size = NULL,
  hjust = NULL,
  vjust = NULL,
  angle = NULL,
  lineheight = NULL,
  margin = NULL,
  margin_x = FALSE,
  margin_y = FALSE,
  ...
) {
  check_device_compatibility()

  if (is.null(label) || identical(label, "")) {
    return(ggplot2::zeroGrob())
  }

  # Get base defaults from text_props (which uses flextable defaults)
  base_props <- default_text_props()

  # Resolve properties (parameter > element > text_props defaults)
  hj <- hjust %||% element$hjust %||% 0.5
  vj <- vjust %||% element$vjust %||% 0.5
  margin <- margin %||% element$margin %||% ggplot2::margin()
  size <- size %||% element$size %||% base_props$font.size
  colour <- colour %||% element$colour %||% base_props$font.color
  family <- family %||% element$family %||% base_props$font.family
  lineheight <- lineheight %||% element$lineheight %||% base_props$line_spacing

  if (is.null(family) || !nzchar(family)) {
    family <- "sans"
  }

  # Handle rotation angle (not from text_props - it's a layout property)
  angle <- angle %||% element$angle %||% 0

  # Create text_props for the grob
  props <- default_text_props(
    font_size = size,
    font_family = family,
    font_color = colour,
    code_font_family = element$code_font_family,
    line_spacing = lineheight
  )

  # Detect explicit positioning (e.g. plot.tag with location = "plot"/"panel")
  has_position <- !is.null(x) || !is.null(y)

  # Create the mdGrob with explicit text_props
  md_gr <- md_grob(
    label,
    x = hj,
    y = vj,
    hjust = hj,
    vjust = vj,
    text_props = props
  )

  dims <- dim(md_gr)
  content_w <- unit(dims$width, "inches")
  content_h <- unit(dims$height, "inches")

  # For rotated text, swap width/height for layout
  if (angle == 90 || angle == 270) {
    layout_w <- content_h
    layout_h <- content_w
  } else {
    layout_w <- content_w
    layout_h <- content_h
  }

  # Auto-wrap for horizontal text with margin_x (titles, captions, etc.)
  # Disabled when explicit position is given (tags don't wrap)
  auto_wrap <- (angle == 0) && margin_x && !has_position

  # Build layout dimensions with margins
  if (margin_x) {
    if (auto_wrap) {
      # Flexible width: content cell fills available space for wrapping
      widths <- unit.c(margin[4], unit(1, "null"), margin[2])
    } else {
      widths <- unit.c(margin[4], layout_w, margin[2])
    }
    ncol_layout <- 3L
    content_col <- 2L
  } else {
    widths <- layout_w
    ncol_layout <- 1L
    content_col <- 1L
  }

  if (margin_y) {
    if (auto_wrap) {
      # Flexible height: resolved dynamically in heightDetails
      heights <- unit.c(margin[1], unit(1, "null"), margin[3])
    } else {
      heights <- unit.c(margin[1], layout_h, margin[3])
    }
    nrow_layout <- 3L
    content_row <- 2L
  } else {
    heights <- layout_h
    nrow_layout <- 1L
    content_row <- 1L
  }

  if (has_position) {
    # Explicit x/y positioning (e.g. plot.tag with location = "plot"/"panel").
    # Position the grob directly at x/y, like ggplot2's titleGrob.
    pos_x <- x %||% unit(hj, "npc")
    pos_y <- y %||% unit(vj, "npc")
    if (angle != 0) {
      angle_mod <- angle %% 360
      if (angle_mod >= 270) {
        rot_hj <- vj
        rot_vj <- 1 - hj
      } else if (angle_mod >= 180) {
        rot_hj <- 1 - hj
        rot_vj <- 1 - vj
      } else if (angle_mod >= 90) {
        rot_hj <- 1 - vj
        rot_vj <- hj
      } else {
        rot_hj <- hj
        rot_vj <- vj
      }
      if (angle_mod == 90 || angle_mod == 270) {
        container_w <- unit(dims$height, "inches")
        container_h <- unit(dims$width, "inches")
      } else {
        container_w <- unit(dims$width, "inches")
        container_h <- unit(dims$height, "inches")
      }
      md_gr$vp <- vpStack(
        viewport(
          x = pos_x,
          y = pos_y,
          width = container_w,
          height = container_h,
          just = c(rot_hj, rot_vj)
        ),
        viewport(
          angle = angle,
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches")
        )
      )
    } else {
      md_gr$vp <- viewport(
        x = pos_x,
        y = pos_y,
        width = unit(dims$width, "inches"),
        height = unit(dims$height, "inches"),
        just = c(hj, vj)
      )
    }
  } else {
    # No explicit position: use layout viewports (titles, captions, axes)
    layout_vp <- viewport(
      layout = grid.layout(
        nrow = nrow_layout,
        ncol = ncol_layout,
        widths = widths,
        heights = heights
      )
    )
    cell_vp <- viewport(
      layout.pos.row = content_row,
      layout.pos.col = content_col
    )

    if (angle != 0) {
      # Transform justification for rotated text (follows ggplot2 rotate_just)
      angle_mod <- angle %% 360
      if (angle_mod >= 270) {
        pos_hj <- vj
        pos_vj <- 1 - hj
      } else if (angle_mod >= 180) {
        pos_hj <- 1 - hj
        pos_vj <- 1 - vj
      } else if (angle_mod >= 90) {
        pos_hj <- 1 - vj
        pos_vj <- hj
      } else {
        pos_hj <- hj
        pos_vj <- vj
      }

      # Container sized for the rotated bounding box
      if (angle_mod == 90 || angle_mod == 270) {
        container_w <- unit(dims$height, "inches")
        container_h <- unit(dims$width, "inches")
      } else {
        container_w <- unit(dims$width, "inches")
        container_h <- unit(dims$height, "inches")
      }

      md_gr$vp <- vpStack(
        layout_vp,
        cell_vp,
        viewport(
          x = unit(pos_hj, "npc"),
          y = unit(pos_vj, "npc"),
          width = container_w,
          height = container_h,
          just = c(pos_hj, pos_vj)
        ),
        viewport(
          angle = angle,
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches")
        )
      )
    } else if (!auto_wrap) {
      md_gr$vp <- vpStack(
        layout_vp,
        cell_vp,
        viewport(
          x = unit(hj, "npc"),
          y = unit(vj, "npc"),
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches"),
          just = c(hj, vj)
        )
      )
    } else {
      md_gr$vp <- vpStack(layout_vp, cell_vp)
    }
  }

  # For sizing, report rotated dimensions so grobWidth/grobHeight are correct
  if (angle == 90 || angle == 270) {
    report_w <- content_h
    report_h <- content_w
  } else {
    report_w <- content_w
    report_h <- content_h
  }

  gTree(
    children = gList(md_gr),
    widths = widths,
    heights = heights,
    content_w = report_w,
    content_h = report_h,
    margin = margin,
    auto_wrap = auto_wrap,
    cl = "mdTitleGrob"
  )
}

#' @export
widthDetails.mdTitleGrob <- function(x) {
  # Always report the natural content width. auto_wrap only affects rendering
  # (makeContent rewraps text to the available width); returning unit(1, "npc")
  # here causes ggplot2 to allocate the full plot width for legend label
  # columns, collapsing the plot panel.
  x$content_w %||% sum(x$widths)
}

#' @export
heightDetails.mdTitleGrob <- function(x) {
  if (!isTRUE(x$auto_wrap)) {
    return(sum(x$heights))
  }

  # Resolve available width for wrapping
  avail_w <- tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )

  if (is.na(avail_w) || !is.finite(avail_w) || avail_w <= 0) {
    return(sum(x$heights))
  }

  # Subtract horizontal margins to get wrap width
  margin <- x$margin
  if (!is.null(margin)) {
    margin_l <- tryCatch(
      convertWidth(margin[4], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    margin_r <- tryCatch(
      convertWidth(margin[2], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    wrap_w <- avail_w - margin_l - margin_r
  } else {
    wrap_w <- avail_w
  }

  # Compute wrapped height
  md_gr <- x$children[[1]]
  md_gr$max_width <- max(wrap_w, 0.1)
  dims <- dim(md_gr)
  content_h <- unit(dims$height, "inches")

  if (!is.null(margin)) {
    margin[1] + content_h + margin[3]
  } else {
    content_h
  }
}

#' @export
makeContent.mdTitleGrob <- function(x) {
  check_device_compatibility()

  if (!isTRUE(x$auto_wrap)) {
    return(x)
  }

  avail_w <- tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )

  if (is.na(avail_w) || !is.finite(avail_w) || avail_w <= 0) {
    return(x)
  }

  margin <- x$margin
  if (!is.null(margin)) {
    margin_l <- tryCatch(
      convertWidth(margin[4], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    margin_r <- tryCatch(
      convertWidth(margin[2], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    wrap_w <- avail_w - margin_l - margin_r
  } else {
    wrap_w <- avail_w
  }

  md_gr <- x$children[[1]]
  md_gr$max_width <- max(wrap_w, 0.1)
  x <- setChildren(x, gList(md_gr))

  x
}

#' @title Merge element_md with Another Element
#' @description
#' Merges an element_md object with another element.
#' @param new New element_md.
#' @param old Old element to merge with.
#' @return Merged element.
#' @exportS3Method ggplot2::merge_element
#' @keywords internal
merge_element.element_md <- function(new, old) {
  props_names <- c(
    "family",
    "code_font_family",
    "face",
    "colour",
    "size",
    "hjust",
    "vjust",
    "angle",
    "lineheight",
    "margin",
    "debug",
    "inherit.blank"
  )
  for (nm in props_names) {
    if (is.null(new[[nm]])) {
      # Try slot (S7/S4) then list access (S3)
      old_val <- tryCatch(
        slot(old, nm),
        error = function(e) {
          tryCatch(old[[nm]], error = function(e2) NULL)
        }
      )
      if (!is.null(old_val)) {
        new[[nm]] <- old_val
      }
    }
  }
  new
}

#' @noRd
`%||%` <- function(a, b) if (!is.null(a)) a else b

#' @title Chunks Theme Element for 'ggplot2'
#' @description
#' A theme element that renders 'flextable' chunks directly in plot titles,
#' subtitles, captions, and other text positions. This allows using
#' superscripts, subscripts, and other formatting not available in markdown.
#' @param chunks A paragraph object created with [flextable::as_paragraph()]
#'   containing chunks such as [flextable::as_chunk()], [flextable::as_sup()],
#'   [flextable::as_sub()], etc.
#' @param hjust Horizontal justification (0-1).
#' @param vjust Vertical justification (0-1).
#' @param angle Text rotation angle in degrees.
#' @param lineheight Line height multiplier.
#' @param margin Margins around the text (use [ggplot2::margin()]).
#' @param debug Show debug rectangles.
#' @param inherit.blank Should this element inherit blank elements.
#' @param size font size
#'
#' @return An element of class `c("element_chunks", "element_text", "element")`.
#' @export
#' @examplesIf require("ggiraph", quietly = TRUE, character.only = TRUE)
#' library(ggplot2)
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
#' # Caption with subscript (H2O)
#' p <- ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   theme_minimal(base_family = "Liberation Sans") +
#'   theme(
#'     plot.caption = element_chunks(
#'       as_paragraph(
#'         as_chunk("Chemical formula: "),
#'         as_chunk("H"),
#'         as_sub("2"),
#'         as_chunk("O")
#'       )
#'     )
#'   )
#'
#' x <- girafe(
#'   ggobj = p,
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#' x
#'
#' # Title with superscript
#' p <- ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   theme_minimal(base_family = "Liberation Sans") +
#'   theme(
#'     plot.title = element_chunks(
#'       as_paragraph(
#'         as_chunk("Model fit: R"),
#'         as_sup("2"),
#'         as_chunk(" = 0.87")
#'       )
#'     )
#'   )
#'
#' x <- girafe(
#'   ggobj = p,
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#'
#' x
element_chunks <- function(
  chunks,
  hjust = NULL,
  vjust = NULL,
  angle = NULL,
  lineheight = NULL,
  size = NULL,
  margin = NULL,
  debug = FALSE,
  inherit.blank = FALSE
) {
  if (!inherits(chunks, c("paragraph", "chunk"))) {
    cli::cli_abort(
      "{.arg chunks} must be a paragraph or chunk object from 'flextable'"
    )
  }

  structure(
    list(
      chunks = chunks,
      hjust = hjust,
      vjust = vjust,
      angle = angle,
      lineheight = lineheight,
      size = size,
      margin = margin,
      debug = debug,
      inherit.blank = inherit.blank
    ),
    class = c("element_chunks", "element_text", "element")
  )
}

#' @export
element_grob.element_chunks <- function(
  element,
  label = "",
  x = NULL,
  y = NULL,
  family = NULL,
  face = NULL,
  colour = NULL,
  size = NULL,
  hjust = NULL,
  vjust = NULL,
  angle = NULL,
  lineheight = NULL,
  margin = NULL,
  margin_x = FALSE,
  margin_y = FALSE,
  ...
) {
  check_device_compatibility()

  chunks <- element$chunks
  if (is.null(chunks)) {
    return(ggplot2::zeroGrob())
  }

  # Convert chunk to paragraph if needed
  if (inherits(chunks, "chunk") && !inherits(chunks, "paragraph")) {
    chunks <- flextable::as_paragraph(chunks)
  }

  # Extract the data.frame from paragraph (list of data.frames)
  if (inherits(chunks, "paragraph")) {
    chunks_df <- chunks[[1]]
  } else {
    chunks_df <- chunks
  }

  # Get base defaults from text_props.
  # Size resolution order: ggplot2 theme-resolved size (passed by calc_element)
  # > element$size (explicitly set by user) > flextable defaults.
  resolved_size <- size %||% element$size
  base_props <- default_text_props(font_size = resolved_size)

  # Resolve properties (parameter > element > text_props defaults)
  hj <- hjust %||% element$hjust %||% 0.5
  vj <- vjust %||% element$vjust %||% 0.5
  margin <- margin %||% element$margin %||% ggplot2::margin()
  lineheight <- lineheight %||% element$lineheight %||% base_props$line_spacing

  # Handle rotation angle

  angle <- angle %||% element$angle %||% 0

  # Detect explicit positioning (e.g. plot.tag with location = "plot"/"panel")
  has_position <- !is.null(x) || !is.null(y)

  # Create the mdGrob using chunks_grob
  md_gr <- chunks_grob(
    chunks_df,
    x = hj,
    y = vj,
    hjust = hj,
    vjust = vj,
    line_spacing = lineheight
  )

  dims <- dim(md_gr)
  content_w <- unit(dims$width, "inches")
  content_h <- unit(dims$height, "inches")

  # For rotated text, swap width/height for layout
  if (angle == 90 || angle == 270) {
    layout_w <- content_h
    layout_h <- content_w
  } else {
    layout_w <- content_w
    layout_h <- content_h
  }

  # Auto-wrap for horizontal text with margin_x (titles, captions, etc.)
  # Disabled when explicit position is given (tags don't wrap)
  auto_wrap <- (angle == 0) && margin_x && !has_position

  # Build layout dimensions with margins
  if (margin_x) {
    if (auto_wrap) {
      widths <- unit.c(margin[4], unit(1, "null"), margin[2])
    } else {
      widths <- unit.c(margin[4], layout_w, margin[2])
    }
    ncol_layout <- 3L
    content_col <- 2L
  } else {
    widths <- layout_w
    ncol_layout <- 1L
    content_col <- 1L
  }

  if (margin_y) {
    if (auto_wrap) {
      heights <- unit.c(margin[1], unit(1, "null"), margin[3])
    } else {
      heights <- unit.c(margin[1], layout_h, margin[3])
    }
    nrow_layout <- 3L
    content_row <- 2L
  } else {
    heights <- layout_h
    nrow_layout <- 1L
    content_row <- 1L
  }

  if (has_position) {
    # Explicit x/y positioning (e.g. plot.tag with location = "plot"/"panel").
    # Position the grob directly at x/y, like ggplot2's titleGrob.
    pos_x <- x %||% unit(hj, "npc")
    pos_y <- y %||% unit(vj, "npc")
    if (angle != 0) {
      angle_mod <- angle %% 360
      if (angle_mod >= 270) {
        rot_hj <- vj
        rot_vj <- 1 - hj
      } else if (angle_mod >= 180) {
        rot_hj <- 1 - hj
        rot_vj <- 1 - vj
      } else if (angle_mod >= 90) {
        rot_hj <- 1 - vj
        rot_vj <- hj
      } else {
        rot_hj <- hj
        rot_vj <- vj
      }
      if (angle_mod == 90 || angle_mod == 270) {
        container_w <- unit(dims$height, "inches")
        container_h <- unit(dims$width, "inches")
      } else {
        container_w <- unit(dims$width, "inches")
        container_h <- unit(dims$height, "inches")
      }
      md_gr$vp <- vpStack(
        viewport(
          x = pos_x,
          y = pos_y,
          width = container_w,
          height = container_h,
          just = c(rot_hj, rot_vj)
        ),
        viewport(
          angle = angle,
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches")
        )
      )
    } else {
      md_gr$vp <- viewport(
        x = pos_x,
        y = pos_y,
        width = unit(dims$width, "inches"),
        height = unit(dims$height, "inches"),
        just = c(hj, vj)
      )
    }
  } else {
    # No explicit position: use layout viewports (titles, captions, axes)
    layout_vp <- viewport(
      layout = grid.layout(
        nrow = nrow_layout,
        ncol = ncol_layout,
        widths = widths,
        heights = heights
      )
    )
    cell_vp <- viewport(
      layout.pos.row = content_row,
      layout.pos.col = content_col
    )

    if (angle != 0) {
      # Transform justification for rotated text (follows ggplot2 rotate_just)
      angle_mod <- angle %% 360
      if (angle_mod >= 270) {
        pos_hj <- vj
        pos_vj <- 1 - hj
      } else if (angle_mod >= 180) {
        pos_hj <- 1 - hj
        pos_vj <- 1 - vj
      } else if (angle_mod >= 90) {
        pos_hj <- 1 - vj
        pos_vj <- hj
      } else {
        pos_hj <- hj
        pos_vj <- vj
      }

      # Container sized for the rotated bounding box
      if (angle_mod == 90 || angle_mod == 270) {
        container_w <- unit(dims$height, "inches")
        container_h <- unit(dims$width, "inches")
      } else {
        container_w <- unit(dims$width, "inches")
        container_h <- unit(dims$height, "inches")
      }

      md_gr$vp <- vpStack(
        layout_vp,
        cell_vp,
        viewport(
          x = unit(pos_hj, "npc"),
          y = unit(pos_vj, "npc"),
          width = container_w,
          height = container_h,
          just = c(pos_hj, pos_vj)
        ),
        viewport(
          angle = angle,
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches")
        )
      )
    } else if (!auto_wrap) {
      md_gr$vp <- vpStack(
        layout_vp,
        cell_vp,
        viewport(
          x = unit(hj, "npc"),
          y = unit(vj, "npc"),
          width = unit(dims$width, "inches"),
          height = unit(dims$height, "inches"),
          just = c(hj, vj)
        )
      )
    } else {
      md_gr$vp <- vpStack(layout_vp, cell_vp)
    }
  }

  # For sizing, report rotated dimensions so grobWidth/grobHeight are correct
  if (angle == 90 || angle == 270) {
    report_w <- content_h
    report_h <- content_w
  } else {
    report_w <- content_w
    report_h <- content_h
  }

  gTree(
    children = gList(md_gr),
    widths = widths,
    heights = heights,
    content_w = report_w,
    content_h = report_h,
    margin = margin,
    auto_wrap = auto_wrap,
    cl = "chunksGrob"
  )
}

#' @export
widthDetails.chunksGrob <- function(x) {
  # Always report the natural content width. See widthDetails.mdTitleGrob.
  x$content_w %||% sum(x$widths)
}

#' @export
heightDetails.chunksGrob <- function(x) {
  if (!isTRUE(x$auto_wrap)) {
    return(sum(x$heights))
  }

  avail_w <- tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )

  if (is.na(avail_w) || !is.finite(avail_w) || avail_w <= 0) {
    return(sum(x$heights))
  }

  margin <- x$margin
  if (!is.null(margin)) {
    margin_l <- tryCatch(
      convertWidth(margin[4], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    margin_r <- tryCatch(
      convertWidth(margin[2], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    wrap_w <- avail_w - margin_l - margin_r
  } else {
    wrap_w <- avail_w
  }

  md_gr <- x$children[[1]]
  md_gr$max_width <- max(wrap_w, 0.1)
  dims <- dim(md_gr)
  content_h <- unit(dims$height, "inches")

  if (!is.null(margin)) {
    margin[1] + content_h + margin[3]
  } else {
    content_h
  }
}

#' @export
makeContent.chunksGrob <- function(x) {
  if (!isTRUE(x$auto_wrap)) {
    return(x)
  }

  avail_w <- tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )

  if (is.na(avail_w) || !is.finite(avail_w) || avail_w <= 0) {
    return(x)
  }

  margin <- x$margin
  if (!is.null(margin)) {
    margin_l <- tryCatch(
      convertWidth(margin[4], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    margin_r <- tryCatch(
      convertWidth(margin[2], "inches", valueOnly = TRUE),
      error = function(e) 0
    )
    wrap_w <- avail_w - margin_l - margin_r
  } else {
    wrap_w <- avail_w
  }

  md_gr <- x$children[[1]]
  md_gr$max_width <- max(wrap_w, 0.1)
  x <- setChildren(x, gList(md_gr))

  x
}

#' @title Merge element_chunks with Another Element
#' @description
#' Merges an element_chunks object with another element.
#' @param new New element_chunks.
#' @param old Old element to merge with.
#' @return Merged element.
#' @exportS3Method ggplot2::merge_element
#' @keywords internal
merge_element.element_chunks <- function(new, old) {
  props_names <- c(
    "chunks",
    "hjust",
    "vjust",
    "angle",
    "lineheight",
    "size",
    "margin",
    "debug",
    "inherit.blank"
  )
  for (nm in props_names) {
    if (is.null(new[[nm]])) {
      old_val <- tryCatch(
        slot(old, nm),
        error = function(e) {
          tryCatch(old[[nm]], error = function(e2) NULL)
        }
      )
      if (!is.null(old_val)) {
        new[[nm]] <- old_val
      }
    }
  }
  new
}
