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
#' Reads an image file and returns a raster suitable
#' for use with grid::rasterGrob().
#' Requires the 'magick' package.
#'
#' @param path Path to image file.
#' @return A raster object, or NULL if unreadable.
#' @noRd
read_image_raster <- function(path) {
  if (is.na(path) || !file.exists(path)) {
    return(NULL)
  }

  if (!has_magick()) {
    return(NULL)
  }

  tryCatch(
    {
      img <- magick::image_read(path)
      grDevices::as.raster(img)
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
