# Equations: chunks with `eq_data` (LaTeX), such as those created by
# flextable::as_equation(). They are measured with equatags::equation_size()
# and drawn with equatags::equation_grob() (glyphs of the math font, R >= 4.3),
# in inline style unless the column `eq_display` is TRUE. Without 'equatags'
# or with R < 4.3, the LaTeX source is written as text instead.

# TRUE when equations can be measured and drawn.
can_draw_equations <- function() {
  getRversion() >= "4.3.0" &&
    requireNamespace("equatags", quietly = TRUE) &&
    "equation_grob" %in% getNamespaceExports("equatags")
}

# Logical vector: the chunks that are equations.
is_equation_chunk <- function(chunks) {
  if (is.null(chunks$eq_data)) {
    return(rep(FALSE, nrow(chunks)))
  }
  !is.na(chunks$eq_data) & nzchar(chunks$eq_data)
}

# When equations can not be drawn, their LaTeX source becomes the text of
# the chunk, between dollars, with a warning (once per session).
equations_as_text <- function(chunks) {
  is_eq <- is_equation_chunk(chunks)
  if (!any(is_eq) || can_draw_equations()) {
    return(chunks)
  }
  cli::cli_warn(
    c(
      "Equations are written as LaTeX source.",
      "i" = "Drawing equations needs the package {.pkg equatags} (>= 0.4.0) and R >= 4.3."
    ),
    .frequency = "once",
    .frequency_id = "munch_equations_as_text"
  )
  chunks$txt[is_eq] <- paste0("$", chunks$eq_data[is_eq], "$")
  chunks$eq_data[is_eq] <- NA_character_
  chunks
}

# Style of the equations: inline unless `eq_display` is TRUE.
equation_display_of <- function(chunks) {
  if (is.null(chunks$eq_display)) {
    return(rep(FALSE, nrow(chunks)))
  }
  chunks$eq_display %in% TRUE
}

# Width, height above the baseline and depth below it (inches) of the
# equations of rows `i`, at the font size of their chunk. An equation that
# can not be measured gets a null size (equation_size() warns).
equation_metrics <- function(chunks, i) {
  out <- data.frame(
    width = rep(0, length(i)),
    height = rep(0, length(i)),
    depth = rep(0, length(i))
  )
  display <- equation_display_of(chunks)[i]
  size <- chunks$font.size[i]
  key <- paste(size, display)
  for (k in unique(key)) {
    j <- which(key == k)
    s <- equatags::equation_size(
      chunks$eq_data[i[j]],
      size = size[j[1]],
      display = display[j[1]]
    )
    ok <- !is.na(s$width)
    out[j[ok], ] <- s[ok, c("width", "height", "depth")]
  }
  out
}

# The grob of an equation chunk, with its baseline at `y` (inches) and its
# left side at `x` (inches).
equation_chunk_grob <- function(chunk, x, y, name = NULL) {
  h <- chunk$ascent
  d <- chunk$descent
  if (h + d <= 0) {
    return(NULL)
  }
  equatags::equation_grob(
    chunk$eq_data,
    size = chunk$font.size,
    display = isTRUE(chunk$eq_display),
    x0 = x,
    y0 = y,
    hjust = 0,
    vjust = d / (h + d),
    colour = chunk$color,
    default.units = "inches",
    name = name
  )
}
