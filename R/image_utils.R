#' Check if magick is available
#'
#' @return TRUE if magick is installed, FALSE otherwise.
#' @noRd
has_magick <- function() {
  requireNamespace("magick", quietly = TRUE)
}

#' Get image dimensions
#'
#' Returns the pixel dimensions of an image file. The dimensions of 'png',
#' 'jpeg' and 'gif' files are read from their header by
#' `officer::image_dims()`, without decoding the image. 'svg' files are read
#' with `magick::image_read()`, which does not need package 'rsvg' as
#' `officer::image_dims()` does. The 'magick' package is still required, as it
#' is used to draw the images.
#'
#' @param path Path to image file.
#' @return List with width and height in pixels, or NULL if unreadable.
#' @noRd
get_image_info <- function(path) {
  if (is.na(path) || !file.exists(path)) {
    cli::cli_warn(c(
      "Image file not found.",
      "x" = "Cannot find file {.path {path}}."
    ))
    return(NULL)
  }

  if (!has_magick()) {
    cli::cli_warn(c(
      "Package 'magick' is required for images in markdown.",
      "i" = "Install it with {.code install.packages(\"magick\")}."
    ))
    return(NULL)
  }

  tryCatch(
    {
      if (grepl("\\.svg$", path, ignore.case = TRUE)) {
        info <- magick::image_info(magick::image_read(path))
        list(width = info$width, height = info$height)
      } else {
        dims <- officer::image_dims(path)
        list(width = unname(dims[["width"]]), height = unname(dims[["height"]]))
      }
    },
    error = function(e) {
      cli::cli_warn(c(
        "Failed to read image.",
        "x" = "Could not read {.path {path}}.",
        "i" = conditionMessage(e)
      ))
      NULL
    }
  )
}

#' Read image as raster
#'
#' Returns a native raster suitable for use with grid::rasterGrob(). It comes
#' from the cache of flextable, an image is only decoded once in a session.
#' Requires the 'magick' package.
#'
#' @param path Path to image file.
#' @param width,height Size in inches at which an SVG file is rendered.
#' @return A native raster, or NULL if unreadable.
#' @noRd
read_image_raster <- function(path, width = NULL, height = NULL) {
  if (is.na(path) || !file.exists(path)) {
    return(NULL)
  }

  if (!has_magick()) {
    return(NULL)
  }

  tryCatch(
    flextable::image_raster(path, width = width, height = height),
    error = function(e) {
      cli::cli_warn(c(
        "Failed to read image.",
        "x" = "Could not read {.path {path}}.",
        "i" = conditionMessage(e)
      ))
      NULL
    }
  )
}

#' Default size of an image in a text
#'
#' Its height is twice the font size, its width keeps its aspect ratio.
#'
#' @param info Size of the image in pixels, from get_image_info().
#' @param font_size Font size in points.
#' @return A list with width and height in inches.
#' @noRd
default_image_size <- function(info, font_size) {
  height <- font_size / 72 * 2
  list(width = height * info$width / info$height, height = height)
}
