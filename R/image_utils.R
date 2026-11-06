#' Check if magick is available
#'
#' @return TRUE if magick is installed, FALSE otherwise.
#' @noRd
has_magick <- function() {
  requireNamespace("magick", quietly = TRUE)
}

#' Get image dimensions
#'
#' Reads an image file and returns its pixel dimensions.
#' Requires the 'magick' package.
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
      img <- magick::image_read(path)
      info <- magick::image_info(img)
      list(width = info$width, height = info$height)
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
