#' @title Draw Markdown Text in ggplot2
#' @description
#' A ggplot2 geom for rendering markdown-formatted text. This geom is similar
#' to [ggplot2::geom_text()] but supports basic markdown formatting
#' (bold, italic, code, strikethrough, links, images).
#'
#' @inheritParams ggplot2::geom_text
#' @param width Maximum width for text wrapping in inches. `NA` (default)
#'   means no wrapping. Use `"auto"` to wrap at the plot panel edge: the wrap
#'   width is computed from each label's `x` position and `hjust` so that text
#'   stays within the panel.
#' @param code_font_family Font family for inline code (backticks).
#'   Defaults to `"mono"` when `NULL`.
#' @param size.unit How the `size` aesthetic is interpreted: as millimetres
#'   (`"mm"`, default), points (`"pt"`), centimetres (`"cm"`), inches (`"in"`),
#'   or picas (`"pc"`).
#' @param na.rm If `FALSE`, the default, missing values are removed with
#'   a warning. If `TRUE`, missing values are silently removed.
#'
#' @return A ggplot2 layer that can be added to a plot.
#'
#' @section Aesthetics:
#' `geom_text_md()` understands the following aesthetics (required in bold):
#' - **`x`**
#' - **`y`**
#' - **`label`**
#' - `alpha`
#' - `angle`
#' - `colour`
#' - `family`
#' - `hjust`
#' - `lineheight`
#' - `size`
#' - `vjust`
#'
#' @details
#' The geom supports the following markdown syntax:
#' - `**bold**` or `__bold__`
#' - `*italic*` or `_italic_`
#' - `` `code` `` (monospace)
#' - `~~strikethrough~~`
#' - `[link](url)` (underlined and colored)
#' - `![alt](path)` (images)
#'
#' Text properties (font size, family, color) are controlled by the
#' `size`, `family`, and `colour` aesthetics respectively.
#'
#' @export
#' @examplesIf require("ggiraph", quietly = TRUE, character.only = TRUE)
#' #
#' library(ggplot2)
#'
#' library(gdtools)
#' font_set_liberation()
#'
#' # -------------------------------------------------------------------
#'
#' # Basic usage with markdown formatting
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = 1:3,
#'   y = 1:3,
#'   label = c("**Bold**", "*Italic*", "`Code`")
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label)) +
#'     geom_text_md(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency(),
#'     liberationmonoHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Customizing size and colour aesthetics
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = c(1, 2, 3),
#'   y = c(1, 2, 3),
#'   label = c(
#'     "**Small** text",
#'     "**Medium** text",
#'     "**Large** text"
#'   ),
#'   size = c(3, 5, 7),
#'   color = c("steelblue", "darkgreen", "firebrick")
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label, size = size, colour = color)) +
#'     geom_text_md(width = 1) +
#'     scale_size_identity() +
#'     scale_colour_identity() +
#'     scale_x_continuous(expand = c(.15, .15)) +
#'     theme_minimal(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency(),
#'     liberationmonoHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Using different font families
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = c(1, 1, 1),
#'   y = c(3, 2, 1),
#'   label = c(
#'     "**Sans-serif** font (*default*)",
#'     "**Serif** font (*elegant*)",
#'     "**Monospace** font (`code style`)"
#'   ),
#'   family = c("Liberation Sans", "Liberation Serif", "Liberation Mono")
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label, family = family)) +
#'     geom_text_md(hjust = 0) +
#'     xlim(0.5, 3) +
#'     theme_void(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency(),
#'     liberationserifHtmlDependency(),
#'     liberationmonoHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Text rotation with angle aesthetic
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = c(1, 2, 3, 4),
#'   y = c(1, 1, 1, 1),
#'   label = "**Rotated** *text*",
#'   angle = c(0, 45, 90, -45)
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label, angle = angle)) +
#'     geom_text_md(size = 4) +
#'     scale_x_continuous(expand = c(.15, .15)) +
#'     ylim(0.5, 1.5) +
#'     theme_minimal(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Justification with hjust and vjust
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = rep(2, 9),
#'   y = rep(2, 9),
#'   hjust = rep(c(0, 0.5, 1), 3),
#'   vjust = rep(c(0, 0.5, 1), each = 3),
#'   label = paste0(
#'     "**h=",
#'     rep(c(0, 0.5, 1), 3),
#'     "**\n*v=",
#'     rep(c(0, 0.5, 1), each = 3),
#'     "*"
#'   )
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label, hjust = hjust, vjust = vjust)) +
#'     geom_point(color = "red", size = 3) +
#'     geom_text_md(size = 3) +
#'     facet_grid(vjust ~ hjust, labeller = label_both) +
#'     xlim(1, 3) +
#'     ylim(1, 3) +
#'     theme_minimal(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Text wrapping with width parameter
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = 1,
#'   y = 1,
#'   label = paste0(
#'     "This is a **long text** that will be *wrapped* ",
#'     "automatically when it exceeds the specified `width`."
#'   )
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label)) +
#'     geom_text_md(width = 2, hjust = 0) +
#'     xlim(0.5, 3) +
#'     theme_void(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency(),
#'     liberationmonoHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Alpha transparency
#' # -------------------------------------------------------------------
#' df <- data.frame(
#'   x = 1:4,
#'   y = rep(1, 4),
#'   label = "**Text**",
#'   alpha = c(1, 0.7, 0.4, 0.2)
#' )
#'
#' x <- girafe(
#'   ggplot(df, aes(x, y, label = label, alpha = alpha)) +
#'     geom_text_md(size = 8) +
#'     scale_alpha_identity() +
#'     theme_minimal(),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency()
#'   )
#' )
#' x
#'
#' # -------------------------------------------------------------------
#' # Practical example: Annotated scatter plot
#' # -------------------------------------------------------------------
#' x <- girafe(
#'   ggplot(mtcars, aes(mpg, wt)) +
#'     geom_point(colour = "steelblue", size = 2) +
#'     geom_smooth(method = "lm", se = FALSE, colour = "firebrick") +
#'     geom_text_md(
#'       label = "**R\u00B2 = 0.75**\n*p < 0.001*\n\n`lm(wt ~ mpg)`",
#'       x = 32,
#'       y = 5,
#'       hjust = 1,
#'       vjust = 1,
#'       size = 3.5,
#'       colour = "gray30"
#'     ) +
#'     labs(
#'       title = "MPG vs Weight",
#'       x = "Miles per Gallon",
#'       y = "Weight (1000 lbs)"
#'     ) +
#'     theme_minimal(base_family = "Liberation Sans"),
#'   options = list(opts_sizing(rescale = FALSE)),
#'   dependencies = list(
#'     liberationsansHtmlDependency(),
#'     liberationmonoHtmlDependency()
#'   )
#' )
#' x
geom_text_md <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  width = NA,
  code_font_family = NULL,
  size.unit = "mm",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomTextMd,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      width = width,
      code_font_family = code_font_family,
      size.unit = size.unit,
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname geom_text_md
#' @format NULL
#' @usage NULL
#' @export
GeomTextMd <- ggplot2::ggproto(
  "GeomTextMd",
  ggplot2::Geom,

  required_aes = c("x", "y", "label"),

  default_aes = ggplot2::aes(
    colour = "black",
    size = 3.88,
    angle = 0,
    hjust = 0.5,
    vjust = 0.5,
    alpha = NA,
    family = "",
    lineheight = 1.2
  ),

  draw_panel = function(
    data,
    panel_params,
    coord,
    width = NA,
    code_font_family = NULL,
    size.unit = "mm",
    na.rm = FALSE
  ) {
    check_device_compatibility()

    # Remove missing values
    data <- data[!is.na(data$label), , drop = FALSE]
    if (nrow(data) == 0) {
      return(grid::nullGrob())
    }

    # Transform coordinates
    data <- coord$transform(data, panel_params)

    # Convert size based on unit
    size_mult <- resolve_text_unit(size.unit)
    fontsize <- data$size * size_mult

    # Handle alpha
    colour <- if (is.na(data$alpha[1])) {
      data$colour
    } else {
      ggplot2::alpha(data$colour, data$alpha)
    }

    # Auto-wrap: defer rendering to makeContent where panel dimensions are known
    if (is.character(width) && identical(width, "auto")) {
      return(gTree(
        data = data,
        fontsize = fontsize,
        colour = colour,
        code_font_family = code_font_family,
        cl = "MdTextAutoWrapGrob"
      ))
    }

    # Create grobs for each label
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, ]

      # Create text properties
      props <- default_text_props(
        font_size = fontsize[i],
        font_family = if (nzchar(row$family)) row$family else "sans",
        font_color = colour[i],
        code_font_family = code_font_family,
        line_spacing = row$lineheight
      )

      # Determine width for wrapping
      wrap_width <- if (is.na(width)) NULL else width

      # Create the markdown grob
      gr <- md_grob(
        md_text = as.character(row$label),
        x = row$x,
        y = row$y,
        hjust = row$hjust,
        vjust = row$vjust,
        width = wrap_width,
        line_spacing = row$lineheight,
        text_props = props
      )

      # Handle rotation
      if (row$angle != 0) {
        gr$vp <- grid::viewport(
          x = grid::unit(row$x, "npc"),
          y = grid::unit(row$y, "npc"),
          angle = row$angle,
          just = c(row$hjust, row$vjust)
        )
      }

      gr
    })

    do.call(grid::grobTree, grobs)
  },

  draw_key = ggplot2::draw_key_text
)

#' @export
#' @importFrom grid makeContent setChildren gList
makeContent.MdTextAutoWrapGrob <- function(x) {
  check_device_compatibility()

  panel_w <- tryCatch(
    convertWidth(unit(1, "npc"), "inches", valueOnly = TRUE),
    error = function(e) NA_real_
  )

  if (is.na(panel_w) || panel_w <= 0) {
    return(setChildren(x, gList(nullGrob())))
  }

  data <- x$data

  grobs <- lapply(seq_len(nrow(data)), function(i) {
    row <- data[i, ]
    hj <- max(0, min(1, row$hjust))
    # Clamp x to [0, 1] before computing available inches
    xc <- max(0, min(1, row$x))

    # Max width before text overflows the panel edge, given hjust
    avail_w <- if (hj <= 0) {
      (1 - xc) * panel_w
    } else if (hj >= 1) {
      xc * panel_w
    } else {
      min(xc / hj, (1 - xc) / (1 - hj)) * panel_w
    }
    wrap_width <- max(avail_w, 0.1)

    props <- default_text_props(
      font_size = x$fontsize[i],
      font_family = if (nzchar(row$family)) row$family else "sans",
      font_color = x$colour[i],
      code_font_family = x$code_font_family,
      line_spacing = row$lineheight
    )

    gr <- md_grob(
      md_text = as.character(row$label),
      x = row$x,
      y = row$y,
      hjust = row$hjust,
      vjust = row$vjust,
      width = wrap_width,
      line_spacing = row$lineheight,
      text_props = props
    )

    if (row$angle != 0) {
      gr$vp <- grid::viewport(
        x = unit(row$x, "npc"),
        y = unit(row$y, "npc"),
        angle = row$angle,
        just = c(row$hjust, row$vjust)
      )
    }

    gr
  })

  setChildren(x, do.call(gList, grobs))
}

#' @title Draw Markdown Text with a Background Box in ggplot2
#' @description
#' A ggplot2 geom for rendering markdown-formatted text with a background
#' rectangle, similar to [ggplot2::geom_label()]. Supports basic markdown
#' formatting (bold, italic, code, strikethrough, links, images).
#' @inheritParams geom_text_md
#' @param label.padding Amount of padding around label (defaults to 0.25 lines).
#' @param label.r Radius of rounded corners (defaults to 0.15 lines).
#' @param label.size Size of label border in mm.
#'
#' @return A ggplot2 layer that can be added to a plot.
#'
#' @section Aesthetics:
#' `geom_label_md()` understands the following aesthetics (required in bold):
#' - **`x`**
#' - **`y`**
#' - **`label`**
#' - `alpha`
#' - `angle`
#' - `colour`
#' - `family`
#' - `fill`
#' - `hjust`
#' - `lineheight`
#' - `size`
#' - `vjust`
#'
#' @details
#' The geom supports the same markdown syntax as [geom_text_md()].
#'
#' The `fill` aesthetic controls the background color of the label box,
#' while `colour` controls both the text color and the border color.
#'
#' @export
#' @example inst/examples/geom_label_md.R
geom_label_md <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  width = NA,
  code_font_family = NULL,
  label.padding = unit(0.25, "lines"),
  label.r = unit(0.15, "lines"),
  label.size = 0.25,
  size.unit = "mm",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomLabelMd,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      width = width,
      code_font_family = code_font_family,
      label.padding = label.padding,
      label.r = label.r,
      label.size = label.size,
      size.unit = size.unit,
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname geom_label_md
#' @format NULL
#' @usage NULL
#' @export
GeomLabelMd <- ggplot2::ggproto(
  "GeomLabelMd",
  ggplot2::Geom,

  required_aes = c("x", "y", "label"),

  default_aes = ggplot2::aes(
    colour = "black",
    fill = "white",
    size = 3.88,
    angle = 0,
    hjust = 0.5,
    vjust = 0.5,
    alpha = NA,
    family = "",
    lineheight = 1.2
  ),

  draw_panel = function(
    data,
    panel_params,
    coord,
    width = NA,
    code_font_family = NULL,
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    label.size = 0.25,
    size.unit = "mm",
    na.rm = FALSE
  ) {
    check_device_compatibility()

    # Remove missing values
    data <- data[!is.na(data$label), , drop = FALSE]
    if (nrow(data) == 0) {
      return(grid::nullGrob())
    }

    # Transform coordinates
    data <- coord$transform(data, panel_params)

    # Convert size based on unit
    size_mult <- resolve_text_unit(size.unit)
    fontsize <- data$size * size_mult

    # Handle alpha for text
    text_colour <- if (is.na(data$alpha[1])) {
      data$colour
    } else {
      ggplot2::alpha(data$colour, data$alpha)
    }

    # Handle alpha for fill
    fill_colour <- if (is.na(data$alpha[1])) {
      data$fill
    } else {
      ggplot2::alpha(data$fill, data$alpha)
    }

    # Create grobs for each label
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, ]

      # Create text properties
      props <- default_text_props(
        font_size = fontsize[i],
        font_family = if (nzchar(row$family)) row$family else "sans",
        font_color = text_colour[i],
        code_font_family = code_font_family,
        line_spacing = row$lineheight
      )

      # Determine width for wrapping
      wrap_width <- if (is.na(width)) NULL else width

      # Create the markdown grob to get dimensions
      md_gr <- md_grob(
        md_text = as.character(row$label),
        x = 0.5,
        y = 0.5,
        hjust = 0.5,
        vjust = 0.5,
        width = wrap_width,
        line_spacing = row$lineheight,
        text_props = props
      )

      # Get dimensions
      dims <- dim(md_gr)

      # Convert padding to inches
      padding_inch <- grid::convertUnit(
        label.padding,
        "inches",
        valueOnly = TRUE
      )

      # Total box dimensions
      box_width <- dims$width + 2 * padding_inch
      box_height <- dims$height + 2 * padding_inch

      # Create background rectangle
      bg_grob <- grid::roundrectGrob(
        x = unit(row$x, "npc"),
        y = unit(row$y, "npc"),
        width = unit(box_width, "inches"),
        height = unit(box_height, "inches"),
        just = c(row$hjust, row$vjust),
        r = label.r,
        gp = grid::gpar(
          fill = fill_colour[i],
          col = if (label.size > 0) text_colour[i] else NA,
          lwd = label.size * ggplot2::.pt
        )
      )

      # Calculate text offset based on hjust/vjust for proper padding
      # When hjust=0, text should be offset right by padding
      # When hjust=1, text should be offset left by padding
      # When hjust=0.5, no offset needed (centered)
      x_offset <- padding_inch * (1 - 2 * row$hjust)
      y_offset <- padding_inch * (1 - 2 * row$vjust)

      # Create the markdown grob positioned inside the box
      text_gr <- md_grob(
        md_text = as.character(row$label),
        x = 0.5,
        y = 0.5,
        hjust = row$hjust,
        vjust = row$vjust,
        width = wrap_width,
        line_spacing = row$lineheight,
        text_props = props
      )

      # Override the viewport to position text with padding offset; lines
      # are aligned within the wrapping width when given
      text_w <- wrap_width %||% dims$width
      text_gr$vp <- grid::viewport(
        x = unit(row$x, "npc") + unit(x_offset, "inches"),
        y = unit(row$y, "npc") + unit(y_offset, "inches"),
        width = unit(text_w, "inches"),
        height = unit(dims$height, "inches"),
        just = c(row$hjust, row$vjust)
      )

      # Handle rotation
      if (row$angle != 0) {
        bg_grob$vp <- grid::viewport(
          x = grid::unit(row$x, "npc"),
          y = grid::unit(row$y, "npc"),
          angle = row$angle,
          just = c(row$hjust, row$vjust)
        )
        text_gr$vp <- grid::viewport(
          x = unit(row$x, "npc") + unit(x_offset, "inches"),
          y = unit(row$y, "npc") + unit(y_offset, "inches"),
          width = unit(text_w, "inches"),
          height = unit(dims$height, "inches"),
          angle = row$angle,
          just = c(row$hjust, row$vjust)
        )
      }

      grid::grobTree(bg_grob, text_gr)
    })

    do.call(grid::grobTree, grobs)
  },

  draw_key = ggplot2::draw_key_label
)

#' Resolve text size unit to points multiplier
#' Copied from ggplot2
#' @param unit Character: "mm", "pt", "cm", "in", or "pc".
#' @return Numeric multiplier to convert to points.
#' @noRd
resolve_text_unit <- function(unit) {
  unit <- match.arg(unit, c("mm", "pt", "cm", "in", "pc"))
  switch(
    unit,
    "mm" = ggplot2::.pt,
    "cm" = ggplot2::.pt * 10,
    "in" = 72.27,
    "pc" = 12,
    1
  )
}
