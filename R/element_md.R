#' @title Markdown Theme Element for ggplot2
#' @description
#' A theme element that renders text labels as markdown.
#' Use in place of [ggplot2::element_text()] for plot titles,
#' subtitles, captions, axis labels, etc.
#'
#' @param family Font family.
#' @param code_font_family Font family for inline code. `NA`, the default,
#'   takes the font of the theme element it inherits from, else `"mono"`.
#' @param face Font face ("plain", "bold", "italic", "bold.italic").
#' @param colour,color Text color.
#' @param size Font size in points.
#' @param hjust Horizontal justification (0-1).
#' @param vjust Vertical justification (0-1).
#' @param angle Text rotation angle in degrees.
#' @param lineheight Line height multiplier.
#' @param margin Margins around the text (use [ggplot2::margin()]).
#' @param width Maximum width of the text in inches, for titles, subtitles and
#'   captions, which wrap to their available width by default. With 'patchwork' or a
#'   fixed aspect ratio, the available width is not known when the height of the
#'   title is computed: the text may need more lines than the space kept for it,
#'   and setting `width` solves this. It is ignored for rotated text and for text
#'   with an explicit position. `NA`, the default, sets no width.
#' @param debug Show debug rectangles.
#' @param inherit.blank Should this element inherit blank elements.
#'
#' @return An S7 element of class `element_md`, which extends
#'   [ggplot2::element_text()].
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
element_md <- S7::new_class(
  "element_md",
  parent = ggplot2::element_text,
  package = NULL,
  properties = list(
    code_font_family = S7::new_union(NULL, S7::class_character),
    width = S7::new_union(NULL, S7::class_numeric)
  ),
  constructor = function(
    family = NULL,
    code_font_family = NA_character_,
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
    inherit.blank = FALSE,
    width = NA_real_
  ) {
    if (!is.null(color)) {
      colour <- color
    }
    check_title_width(width)
    # NULL and NA both mean unset: the root element `text` of a theme can not
    # have NULL properties
    if (is_unset_value(width)) {
      width <- NA_real_
    }
    if (is_unset_value(code_font_family)) {
      code_font_family <- NA_character_
    }
    S7::new_object(
      ggplot2::element_text(
        family = family,
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
      code_font_family = code_font_family,
      width = width
    )
  }
)

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
  # an empty family, the default of the themes, does not set the font
  family <- theme_font_family(family %||% element$family) %||%
    base_props$font.family
  lineheight <- lineheight %||% element$lineheight %||% base_props$line_spacing

  # Handle rotation angle (not from text_props - it's a layout property)
  angle <- angle %||% element$angle %||% 0

  # font face of the text, markdown emphasis adds to it
  face <- face %||% element$face %||% "plain"

  # Create text_props for the grob
  props <- default_text_props(
    font_size = size,
    font_family = family,
    font_color = colour,
    code_font_family = unset_as_null(element$code_font_family),
    line_spacing = lineheight,
    bold = face %in% c("bold", "bold.italic", 2, 4),
    italic = face %in% c("italic", "bold.italic", 3, 4)
  )

  # Several labels at given positions (axis ticks, colour bars, polar axes),
  # and texts with an angle that is not a right angle: drawn as titleGrob()
  # of 'ggplot2', rotated around their anchor in a cell of their rotated size
  if (is_label_set(label, x, y, margin_x, margin_y) || angle %% 90 != 0) {
    return(md_labels_grob(
      label = label,
      x = x,
      y = y,
      hjust = hj,
      vjust = vj,
      angle = angle,
      text_props = props,
      margin = margin,
      margin_x = margin_x,
      margin_y = margin_y
    ))
  }

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
    # The layout has the size of the text in a direction without margins:
    # justify it in its cell, as titleGrob() of ggplot2 places its text at
    # hjust and vjust. Centred, hjust of an axis title had no effect.
    layout_vp <- viewport(
      layout = grid.layout(
        nrow = nrow_layout,
        ncol = ncol_layout,
        widths = widths,
        heights = heights,
        just = rotate_text_just(hj, vj, angle)
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
    wrap_width = unset_as_null(element$width),
    cl = "mdTitleGrob"
  )
}

#' @export
widthDetails.mdTitleGrob <- function(x) {
  # Always report the natural content width. auto_wrap only affects rendering
  # (makeContent rewraps text to the available width); returning unit(1, "npc")
  # here causes ggplot2 to allocate the full plot width for legend label
  # columns, collapsing the plot panel.
  title_natural_width(x)
}

#' Natural width of a title, with its left and right margins
#'
#' The margins are included as in the titles of 'ggplot2': legends size the
#' column of their labels with this width, and the text wraps to the width of
#' the column minus the margins. Without them, the widest label wrapped and
#' overflowed on the next key.
#' @param x A title grob.
#' @return A unit, in inches.
#' @noRd
title_natural_width <- function(x) {
  if (is.null(x$content_w)) {
    return(sum(x$widths))
  }
  width <- x$content_w
  if (length(x$widths) == 3L && !is.null(x$margin)) {
    width <- x$margin[4] + width + x$margin[2]
  }
  unit(convertWidth(width, "inches", valueOnly = TRUE), "inches")
}

#' @export
heightDetails.mdTitleGrob <- function(x) {
  title_height(x)
}

#' @export
makeContent.mdTitleGrob <- function(x) {
  check_device_compatibility()
  title_set_wrap_width(x)
}

#' Width of the column of a title in the gtable being drawn
#'
#' A row of a gtable is sized before its columns are known: when 'ggplot2' asks
#' for the height of a title, the only available width is the one of the whole
#' plot, which is wider than the panel. No function gives this width, so that it
#' is computed from the gtable found in the calls of `grid::drawGTree()`.
#'
#' The result is too large with fixed aspect ratios, as the columns also depend on
#' the rows.
#'
#' @param x A title grob.
#' @return Width in inches, or NULL if the title is not being drawn in a gtable,
#'   which is the case when 'patchwork' asks for its height.
#' @noRd
gtable_column_width <- function(x) {
  is_draw <- vapply(
    sys.calls(),
    function(call) identical(call[[1]], quote(drawGTree)),
    logical(1)
  )
  # only these frames are read: their `x` has already been evaluated
  for (frame in rev(sys.frames()[is_draw])) {
    tree <- frame$x
    if (!inherits(tree, "gtable")) {
      next
    }
    is_title <- vapply(
      tree$grobs,
      function(grob) identical(grob$name, x$name),
      logical(1)
    )
    if (!any(is_title)) {
      next
    }

    widths <- tree$widths
    is_null <- unitType(widths) == "null"
    inches <- numeric(length(widths))
    inches[!is_null] <- vapply(
      which(!is_null),
      function(i) convertWidth(widths[i], "inches", valueOnly = TRUE),
      numeric(1)
    )
    # null columns share what the others leave
    free <- convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE) -
      sum(inches)
    weights <- as.numeric(widths[is_null])
    inches[is_null] <- max(free, 0) * weights / sum(weights)

    layout <- tree$layout[which(is_title)[1], ]
    return(sum(inches[layout$l:layout$r]))
  }
  NULL
}

#' Maximum width of the text of a title
#'
#' @param x A title grob.
#' @param available Width available for the title and its margins, in inches.
#' @return Width in inches: the `width` of the element if there is one, else the
#'   available width without margins. NULL if there is no usable width.
#' @noRd
title_wrap_width <- function(x, available) {
  if (!is.null(x$wrap_width)) {
    return(x$wrap_width)
  }
  if (is.na(available) || !is.finite(available) || available <= 0) {
    return(NULL)
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
    available <- available - margin_l - margin_r
  }
  max(available, 0.1)
}

viewport_width <- function() {
  tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )
}

#' Height of a title, computed for the width it will be drawn with
#' @param x A title grob.
#' @return A unit.
#' @noRd
title_height <- function(x) {
  if (!isTRUE(x$auto_wrap)) {
    return(sum(x$heights))
  }
  if (is_legend_text(x)) {
    # not wrapped: the height of its single line, the content row is "null"
    margin <- x$margin %||% ggplot2::margin()
    return(margin[1] + x$content_h + margin[3])
  }

  available <- tryCatch(gtable_column_width(x), error = function(e) NULL)
  wrap_width <- title_wrap_width(x, available %||% viewport_width())
  if (is.null(wrap_width)) {
    return(sum(x$heights))
  }

  md_gr <- x$children[[1]]
  md_gr$max_width <- wrap_width
  content_h <- unit(dim(md_gr)$height, "inches")

  margin <- x$margin
  if (!is.null(margin)) {
    margin[1] + content_h + margin[3]
  } else {
    content_h
  }
}

#' Set the width at which the text of a title wraps, when it is drawn
#' @param x A title grob.
#' @return The title grob.
#' @noRd
title_set_wrap_width <- function(x) {
  if (!isTRUE(x$auto_wrap)) {
    return(x)
  }
  if (is_legend_text(x)) {
    # not wrapped: placed at hjust in its cell and overflowing it, as
    # titleGrob() of ggplot2
    md_gr <- x$children[[1]]
    md_gr$vp <- vpStack(
      md_gr$vp,
      viewport(
        x = unit(md_gr$hjust, "npc"),
        width = x$content_w,
        just = c(md_gr$hjust, 0.5)
      )
    )
    return(setChildren(x, gList(md_gr)))
  }

  wrap_width <- title_wrap_width(x, viewport_width())
  if (is.null(wrap_width)) {
    return(x)
  }

  md_gr <- x$children[[1]]
  md_gr$max_width <- wrap_width
  setChildren(x, gList(md_gr))
}

#' @noRd
check_title_width <- function(width) {
  if (is_unset_value(width)) {
    return(invisible(NULL))
  }
  if (!is.numeric(width) || length(width) != 1L || is.na(width) || width <= 0) {
    cli::cli_abort("{.arg width} must be a positive number, in inches.")
  }
  invisible(NULL)
}


#' @noRd
`%||%` <- function(a, b) if (!is.null(a)) a else b

#' @title Chunks Theme Element for 'ggplot2'
#' @description
#' A theme element that renders 'flextable' chunks directly in plot titles,
#' subtitles, captions, and other text positions. This allows using
#' superscripts, subscripts, and other formatting not available in markdown.
#'
#' The format of each chunk comes from the chunk itself, for example
#' `as_chunk(props = fp_text_lite(font.size = 14))`; what the chunk does not
#' set comes from the theme (size, font family, colour and face, as for other
#' texts of the plot, or `size` of the element), and what the theme does not
#' set comes from [flextable::set_flextable_defaults()].
#' @param chunks A paragraph object created with [flextable::as_paragraph()]
#'   containing chunks such as [flextable::as_chunk()], [flextable::as_sup()],
#'   [flextable::as_sub()], etc.
#' @param hjust Horizontal justification (0-1).
#' @param vjust Vertical justification (0-1).
#' @param angle Text rotation angle in degrees.
#' @param lineheight Line height multiplier.
#' @param margin Margins around the text (use [ggplot2::margin()]).
#' @param width Maximum width of the text in inches, for titles, subtitles and
#'   captions, which wrap to their available width by default. With 'patchwork' or a
#'   fixed aspect ratio, the available width is not known when the height of the
#'   title is computed: the text may need more lines than the space kept for it,
#'   and setting `width` solves this. It is ignored for rotated text and for text
#'   with an explicit position. `NA`, the default, sets no width.
#' @param debug Show debug rectangles.
#' @param inherit.blank Should this element inherit blank elements.
#' @param size Font size in points of the chunks that do not set theirs. By
#'   default, the size of the theme.
#'
#' @return An S7 element of class `element_chunks`, which extends
#'   [ggplot2::element_text()].
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
element_chunks <- S7::new_class(
  "element_chunks",
  parent = ggplot2::element_text,
  package = NULL,
  properties = list(
    chunks = S7::class_any,
    width = S7::new_union(NULL, S7::class_numeric)
  ),
  constructor = function(
    chunks,
    hjust = NULL,
    vjust = NULL,
    angle = NULL,
    lineheight = NULL,
    size = NULL,
    margin = NULL,
    debug = FALSE,
    inherit.blank = FALSE,
    width = NA_real_
  ) {
    check_title_width(width)
    if (is_unset_value(width)) {
      width <- NA_real_
    }
    if (!inherits(chunks, c("paragraph", "chunk"))) {
      cli::cli_abort(
        "{.arg chunks} must be a paragraph or chunk object from 'flextable'"
      )
    }
    # family, face and colour are not arguments: the format comes from the
    # chunks, these properties receive the values of the theme when the
    # element is merged with it
    S7::new_object(
      ggplot2::element_text(
        hjust = hjust,
        vjust = vjust,
        angle = angle,
        lineheight = lineheight,
        size = size,
        margin = margin,
        debug = debug,
        inherit.blank = inherit.blank
      ),
      chunks = chunks,
      width = width
    )
  }
)

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
  if (is_label_set(label, x, y, margin_x, margin_y)) {
    cli::cli_abort(c(
      "{.fn element_chunks} draws one fixed text and can not label axis ticks,
      colour bars or polar axes.",
      "i" = "Use {.fn element_md} for these labels."
    ))
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

  # The format of each chunk comes from the chunk, else from the element and
  # its theme (size, family, colour, face), else from the flextable defaults.
  # An empty family, the default of the themes, does not set the font.
  base_props <- default_text_props()
  family <- theme_font_family(family %||% element$family)
  face <- face %||% element$face %||% "plain"
  text_props <- default_text_props(
    font_size = size %||% element$size,
    font_family = family,
    font_color = colour %||% element$colour,
    bold = face %in% c("bold", "bold.italic", 2, 4),
    italic = face %in% c("italic", "bold.italic", 3, 4)
  )
  chunks_df <- apply_defaults(chunks_df, text_props)

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
    # The layout has the size of the text in a direction without margins:
    # justify it in its cell, as titleGrob() of ggplot2 places its text at
    # hjust and vjust. Centred, hjust of an axis title had no effect.
    layout_vp <- viewport(
      layout = grid.layout(
        nrow = nrow_layout,
        ncol = ncol_layout,
        widths = widths,
        heights = heights,
        just = rotate_text_just(hj, vj, angle)
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
    wrap_width = unset_as_null(element$width),
    cl = "chunksGrob"
  )
}

#' @export
widthDetails.chunksGrob <- function(x) {
  # Always report the natural content width. See widthDetails.mdTitleGrob.
  title_natural_width(x)
}

#' @export
heightDetails.chunksGrob <- function(x) {
  title_height(x)
}

#' @export
makeContent.chunksGrob <- function(x) {
  title_set_wrap_width(x)
}


#' Justification of a rotated text in its cell
#'
#' The horizontal and vertical justification of the box of a text rotated by
#' `angle`, as `rotate_just()` of 'ggplot2' for right angles.
#' @param hjust,vjust Justification of the text.
#' @param angle Rotation angle in degrees.
#' @return A numeric vector of length 2.
#' @noRd
rotate_text_just <- function(hjust, vjust, angle) {
  angle <- angle %% 360
  if (angle >= 270) {
    c(vjust, 1 - hjust)
  } else if (angle >= 180) {
    c(1 - hjust, 1 - vjust)
  } else if (angle >= 90) {
    c(1 - vjust, hjust)
  } else {
    c(hjust, vjust)
  }
}

#' Is a title the title or a label of a legend?
#'
#' The title and the labels of a legend do not wrap. 'ggplot2' gives a label
#' a cell as wide as its text. It gives the title a cell as wide as the keys
#' and labels, adds empty columns when the title is wider, and lets the text
#' overflow its cell. ggplot2 names these grobs "guide.title" and
#' "guide.label".
#' @param x A title grob.
#' @return A logical.
#' @noRd
is_legend_text <- function(x) {
  name <- x$name %||% ""
  startsWith(name, "guide.title") || startsWith(name, "guide.label")
}

#' Is a call to element_grob() a set of labels?
#'
#' 'ggplot2' draws the labels of axis ticks, colour bars and polar axes with
#' one call to `element_grob()`: `label` holds a text per label and `x` or `y`
#' their positions. A single tick label has a position and one margin side; a
#' tag has a position and both margin sides.
#' @noRd
is_label_set <- function(label, x, y, margin_x, margin_y) {
  length(label) > 1L ||
    length(x) > 1L ||
    length(y) > 1L ||
    ((!is.null(x) || !is.null(y)) && !(isTRUE(margin_x) && isTRUE(margin_y)))
}

#' Grob of a set of markdown labels
#'
#' The markdown version of `titleGrob()` of 'ggplot2' for vectors: each label
#' is a markdown text drawn at its position, rotated by `angle` around its
#' anchor, with its justification. The grob has the size of the union of the
#' labels in the direction without position, plus the margins.
#' @noRd
md_labels_grob <- function(
  label,
  x,
  y,
  hjust,
  vjust,
  angle,
  text_props,
  margin,
  margin_x,
  margin_y
) {
  label <- as.character(label)
  n <- max(length(label), length(x), length(y), 1L)
  label <- rep_len(label, n)
  hjust <- rep_len(hjust, n)
  vjust <- rep_len(vjust, n)
  angle <- rep_len(angle, n)

  just <- rotate_label_just(hjust, vjust, angle)
  x <- x %||% unit(just$hjust, "npc")
  y <- y %||% unit(just$vjust, "npc")
  if (!grid::is.unit(x)) x <- unit(x, "npc")
  if (!grid::is.unit(y)) y <- unit(y, "npc")
  x <- rep(x, length.out = n)
  y <- rep(y, length.out = n)

  # the box of each label relative to its anchor, after rotation, in inches
  grobs <- vector("list", n)
  x_min <- x_max <- y_min <- y_max <- numeric(n)
  for (i in seq_len(n)) {
    if (is.na(label[i]) || !nzchar(label[i])) next
    gr <- md_grob(
      label[i],
      x = hjust[i],
      y = vjust[i],
      hjust = hjust[i],
      vjust = vjust[i],
      text_props = text_props
    )
    dims <- dim(gr)
    rad <- angle[i] * pi / 180
    cx <- c(-hjust[i], 1 - hjust[i], 1 - hjust[i], -hjust[i]) * dims$width
    cy <- c(-vjust[i], -vjust[i], 1 - vjust[i], 1 - vjust[i]) * dims$height
    rx <- cx * cos(rad) - cy * sin(rad)
    ry <- cx * sin(rad) + cy * cos(rad)
    x_min[i] <- min(rx)
    x_max[i] <- max(rx)
    y_min[i] <- min(ry)
    y_max[i] <- max(ry)
    gr$dims <- dims
    grobs[[i]] <- gr
  }
  drawn <- !vapply(grobs, is.null, logical(1))
  if (!any(drawn)) {
    return(ggplot2::zeroGrob())
  }
  width <- unit(max(x_max[drawn]) - min(x_min[drawn]), "inches")
  height <- unit(max(y_max[drawn]) - min(y_min[drawn]), "inches")

  # margins, as titleGrob() of 'ggplot2'
  new_width <- NULL
  new_height <- NULL
  if (isTRUE(margin_x)) {
    new_width <- unit.c(margin[4], width, margin[2])
    x <- x - margin[2] * just$hjust + margin[4] * (1 - just$hjust)
  }
  if (isTRUE(margin_y)) {
    new_height <- unit.c(margin[1], height, margin[3])
    y <- y - margin[1] * just$vjust + margin[3] * (1 - just$vjust)
  }
  if (xor(isTRUE(margin_x), isTRUE(margin_y))) {
    new_width <- new_width %||% unit(1, "null")
    new_height <- new_height %||% unit(1, "null")
  }

  for (i in which(drawn)) {
    dims <- grobs[[i]]$dims
    grobs[[i]]$dims <- NULL
    grobs[[i]]$vp <- viewport(
      x = x[i],
      y = y[i],
      width = unit(dims$width, "inches"),
      height = unit(dims$height, "inches"),
      just = c(hjust[i], vjust[i]),
      angle = angle[i]
    )
  }

  gTree(
    children = do.call(gList, grobs[drawn]),
    widths = new_width %||% width,
    heights = new_height %||% height,
    cl = "mdLabelsGrob"
  )
}

#' @export
widthDetails.mdLabelsGrob <- function(x) {
  sum(x$widths)
}

#' @export
heightDetails.mdLabelsGrob <- function(x) {
  sum(x$heights)
}

#' Justification of rotated labels
#'
#' Vectorised `rotate_just()` of 'ggplot2': the justification of the box of
#' each label, rotated by its angle.
#' @noRd
rotate_label_just <- function(hjust, vjust, angle) {
  angle <- angle %% 360
  case <- findInterval(angle, c(0, 90, 180, 270, 360))
  hnew <- hjust
  vnew <- vjust
  i <- case == 2
  hnew[i] <- 1 - vjust[i]
  vnew[i] <- hjust[i]
  i <- case == 3
  hnew[i] <- 1 - hjust[i]
  vnew[i] <- 1 - vjust[i]
  i <- case == 4
  hnew[i] <- vjust[i]
  vnew[i] <- 1 - hjust[i]
  list(hjust = hnew, vjust = vnew)
}

#' Merge a munch element with the element it inherits from
#'
#' The properties that `new` does not set are taken from `old`, for the
#' properties they share: `old` is usually an `element_text()` of the theme,
#' which has no `code_font_family`, `width` or `chunks`.
#' @param new An `element_md()` or `element_chunks()`.
#' @param old The element it inherits from.
#' @return The merged element.
#' @noRd
merge_munch_element <- function(new, old, ...) {
  if (S7::S7_inherits(old)) {
    old_props <- S7::props(old)
  } else if (is.list(old)) {
    old_props <- unclass(old)
  } else {
    return(new)
  }
  new_props <- S7::props(new)
  is_unset <- vapply(new_props, is_unset_value, logical(1))
  idx <- intersect(names(new_props)[is_unset], names(old_props))
  idx <- idx[!vapply(old_props[idx], is_unset_value, logical(1))]
  if (length(idx)) {
    S7::props(new)[idx] <- old_props[idx]
  }
  new
}

#' Merge an element_text() into a munch element
#'
#' 'ggplot2' merges an `element_text()` into the root element `text` to set
#' defaults, for example for the titles and labels of legends. When the root
#' is an `element_md()`, the properties set by the `element_text()` replace
#' its own and the result stays an `element_md()`.
#' @noRd
merge_text_into_munch_element <- function(new, old, ...) {
  new_props <- S7::props(new)
  set <- new_props[lengths(new_props) > 0]
  set <- set[intersect(names(set), names(S7::props(old)))]
  if (length(set)) {
    S7::props(old)[names(set)] <- set
  }
  old
}

#' Is a property of an element unset?
#'
#' `NULL`, or `NA` for `code_font_family` and `width`: as the root element
#' `text` must have all its properties, these have `NA` as default value.
#' @noRd
is_unset_value <- function(x) {
  is.null(x) || (length(x) == 1L && is.atomic(x) && is.na(x))
}

#' @noRd
unset_as_null <- function(x) {
  if (is_unset_value(x)) NULL else x
}

# registered by S7::methods_register() in .onLoad()
S7::`method<-`(
  ggplot2::merge_element,
  list(element_md, S7::class_any),
  value = merge_munch_element
)
S7::`method<-`(
  ggplot2::merge_element,
  list(element_chunks, S7::class_any),
  value = merge_munch_element
)
S7::`method<-`(
  ggplot2::merge_element,
  list(ggplot2::element_text, element_md),
  value = merge_text_into_munch_element
)
