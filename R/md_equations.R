# Equations in markdown: `$...$` (inline) and `$$...$$` (display), found with
# the rules of Pandoc (extension `tex_math_dollars`) before commonmark reads
# the text, so that markdown never touches their content (`_` and `*` are
# frequent in LaTeX):
#
# - the opening `$` is followed by a non-space character; the next `$` closes
#   the equation if it is preceded by a non-space character and not followed
#   by a digit, otherwise there is no equation ("$20,000 and $30,000" is not
#   an equation);
# - `\$` is a dollar; inside an equation, a backslash escapes the next
#   character (`\$` is a dollar of LaTeX);
# - `$$...$$` is a display equation, its content may be surrounded by spaces;
# - an equation does not contain a blank line, and there are no equations in
#   code (`` `...` ``).
#
# Each equation is replaced by a marker made of characters of the private
# use area of Unicode, which commonmark keeps in its text nodes:
# U+E000, the number of the equation, U+E001.

eq_marker_open <- "\uE000"
eq_marker_close <- "\uE001"

# Replaces the equations of `x` (one string) by markers. Returns the text and
# the equations (LaTeX and display style).
protect_equations <- function(x) {
  none <- list(text = x, tex = character(0), display = logical(0))
  if (is.na(x) || !grepl("$", x, fixed = TRUE)) {
    return(none)
  }
  ch <- strsplit(x, "")[[1]]
  n <- length(ch)
  out <- character(0)
  tex <- character(0)
  display <- logical(0)
  is_space <- function(k) k > n || k < 1 || grepl("^\\s$", ch[k], perl = TRUE)
  # first character of the first blank line after `from` (n + 1 if none):
  # an equation stops before it
  blank_line_at <- function(from) {
    if (from > n) {
      return(n + 1L)
    }
    m <- regexpr("\n[ \t]*\n", paste(ch[from:n], collapse = ""))
    if (m < 0) n + 1L else from + as.integer(m) - 1L
  }
  add_equation <- function(content, is_display) {
    tex <<- c(tex, content)
    display <<- c(display, is_display)
    out <<- c(out, eq_marker_open, length(tex), eq_marker_close)
  }

  i <- 1L
  while (i <= n) {
    c1 <- ch[i]
    if (c1 == "\\") {
      # escaped character, `\$` included: commonmark unescapes it
      out <- c(out, ch[i:min(i + 1L, n)])
      i <- i + 2L
      next
    }
    if (c1 == "`") {
      # code span: from a run of backticks to the next run of the same length
      run <- 1L
      while (i + run <= n && ch[i + run] == "`") run <- run + 1L
      j <- i + run
      end <- NA_integer_
      while (j <= n) {
        if (ch[j] == "`") {
          r <- 1L
          while (j + r <= n && ch[j + r] == "`") r <- r + 1L
          if (r == run) {
            end <- j + r - 1L
            break
          }
          j <- j + r
        } else {
          j <- j + 1L
        }
      }
      last <- if (is.na(end)) i + run - 1L else end
      out <- c(out, ch[i:last])
      i <- last + 1L
      next
    }
    if (c1 != "$") {
      out <- c(out, c1)
      i <- i + 1L
      next
    }

    if (i < n && ch[i + 1L] == "$") {
      # display equation: up to the next `$$`
      j <- i + 2L
      end <- NA_integer_
      limit <- blank_line_at(i + 2L)
      while (j < n && j < limit) {
        if (ch[j] == "\\") {
          j <- j + 2L
          next
        }
        if (ch[j] == "$" && ch[j + 1L] == "$") {
          end <- j
          break
        }
        j <- j + 1L
      }
      if (!is.na(end)) {
        content <- trimws(paste(ch[seq_len(end - i - 2L) + i + 1L], collapse = ""))
        if (nzchar(content)) {
          add_equation(content, TRUE)
          i <- end + 2L
          next
        }
      }
      out <- c(out, "$", "$")
      i <- i + 2L
      next
    }

    # inline equation
    end <- NA_integer_
    if (!is_space(i + 1L)) {
      j <- i + 1L
      limit <- blank_line_at(i + 1L)
      while (j <= n && j < limit) {
        if (ch[j] == "\\") {
          j <- j + 2L
          next
        }
        if (ch[j] == "$") {
          # only the first dollar can close the equation, as in Pandoc
          if (!is_space(j - 1L) && !(j < n && grepl("[0-9]", ch[j + 1L]))) {
            end <- j
          }
          break
        }
        j <- j + 1L
      }
    }
    if (!is.na(end)) {
      add_equation(paste(ch[(i + 1L):(end - 1L)], collapse = ""), FALSE)
      i <- end + 1L
      next
    }
    out <- c(out, "$")
    i <- i + 1L
  }
  list(text = paste(out, collapse = ""), tex = tex, display = display)
}

# Splits a text containing markers into pieces: list of texts and equation
# numbers, in order (texts as character, equations as integer).
split_equation_markers <- function(txt) {
  pattern <- paste0(eq_marker_open, "([0-9]+)", eq_marker_close)
  if (is.na(txt) || !grepl(eq_marker_open, txt, fixed = TRUE)) {
    return(list(txt))
  }
  m <- gregexpr(pattern, txt, perl = TRUE)[[1]]
  starts <- as.integer(m)
  ends <- starts + attr(m, "match.length") - 1L
  pieces <- list()
  pos <- 1L
  for (k in seq_along(starts)) {
    if (starts[k] > pos) {
      pieces <- c(pieces, list(substr(txt, pos, starts[k] - 1L)))
    }
    number <- substr(txt, starts[k] + 1L, ends[k] - 1L)
    pieces <- c(pieces, list(as.integer(number)))
    pos <- ends[k] + 1L
  }
  if (pos <= nchar(txt)) {
    pieces <- c(pieces, list(substr(txt, pos, nchar(txt))))
  }
  pieces
}

# Puts the display equations of a paragraph alone on their line: the spaces
# around them are removed and line breaks are added between them and the
# text before and after.
display_equations_on_own_line <- function(chunks) {
  if (is.null(chunks) || nrow(chunks) == 0 || is.null(chunks$eq_display)) {
    return(chunks)
  }
  is_display <- chunks$eq_display %in% TRUE
  if (!any(is_display)) {
    return(chunks)
  }
  is_blank <- !is.na(chunks$txt) & grepl("^\\s*$", chunks$txt) &
    !chunks$txt %in% c("\n", "\n\n")
  keep <- rep(TRUE, nrow(chunks))
  for (k in which(is_display)) {
    j <- k - 1L
    while (j >= 1L && is_blank[j]) {
      keep[j] <- FALSE
      j <- j - 1L
    }
    j <- k + 1L
    while (j <= nrow(chunks) && is_blank[j]) {
      keep[j] <- FALSE
      j <- j + 1L
    }
  }
  # trailing and leading spaces of the texts next to the equations
  for (k in which(is_display)) {
    before <- rev(which(keep[seq_len(k - 1L)]))[1]
    if (!is.na(before) && !is.na(chunks$txt[before])) {
      chunks$txt[before] <- sub("\\s+$", "", chunks$txt[before])
    }
    after <- which(keep & seq_len(nrow(chunks)) > k)[1]
    if (!is.na(after) && !is.na(chunks$txt[after])) {
      chunks$txt[after] <- sub("^\\s+", "", chunks$txt[after])
    }
  }
  chunks <- chunks[keep, , drop = FALSE]
  is_display <- chunks$eq_display %in% TRUE
  is_break <- !is.na(chunks$txt) & chunks$txt %in% c("\n", "\n\n")

  rows <- list()
  n <- nrow(chunks)
  for (k in seq_len(n)) {
    if (is_display[k] && k > 1L && !is_break[k - 1L]) {
      rows <- c(rows, list(chunk_dataframe(txt = "\n")))
    }
    rows <- c(rows, list(chunks[k, , drop = FALSE]))
    if (is_display[k] && k < n && !is_break[k + 1L]) {
      rows <- c(rows, list(chunk_dataframe(txt = "\n")))
    }
  }
  out <- do.call(rbind_chunks, rows)
  # texts emptied by the removal of their spaces
  out[is.na(out$txt) | nzchar(out$txt) | !is.na(out$eq_data), , drop = FALSE]
}
