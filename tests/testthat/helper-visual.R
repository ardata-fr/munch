base_theme <- function() {
  ggplot2::theme_minimal(base_size = 12, base_family = "Liberation Sans") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.caption = ggplot2::element_text(size = 9)
    )
}
system_theme <- function() {
  ggplot2::theme_minimal(base_size = 12, base_family = "Arial") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.caption = ggplot2::element_text(size = 9)
    )
}

skip_if_no_system_fonts <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    gdtools::font_family_exists("Arial", system_only = TRUE),
    "Arial not available at system level"
  )
  testthat::skip_if_not(
    gdtools::font_family_exists("Courier New", system_only = TRUE),
    "Courier New not available at system level"
  )
}

visual_renderers <- list(
  ragg = list(
    render = function(p, width, height, res) {
      gdtools::font_set_liberation()
      path <- tempfile(fileext = ".png")
      ragg::agg_png(
        path,
        width = width,
        height = height,
        units = "in",
        res = res
      )
      on.exit(dev.off())
      print(p)
      path
    },
    skip = function() {
      testthat::skip_if_not_installed("ragg")
    },
    tolerance = 0.001
  )#,
  # cairo_pdf = list(
  #   render = function(p, width, height, res) {
  #     gdtools::font_set(sans = "Arial", mono = "Courier New")
  #     pdf_path <- tempfile(fileext = ".pdf")
  #     png_path <- tempfile(fileext = ".png")
  #     grDevices::cairo_pdf(pdf_path, width = width, height = height)
  #     on.exit(dev.off())
  #     print(p)
  #     dev.off()
  #     on.exit()
  #     img <- magick::image_read_pdf(pdf_path, density = res)
  #     magick::image_write(img, png_path, format = "png")
  #     png_path
  #   },
  #   skip = function() {
  #     skip_if_no_system_fonts()
  #     testthat::skip_if_not_installed("magick")
  #   },
  #   tolerance = 0.001
  # )
)
