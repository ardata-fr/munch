plot_files <- sort(list.files(
  testthat::test_path("plots"),
  pattern = "\\.R$",
  full.names = TRUE
))

for (plot_file in plot_files) {
  plot_name <- tools::file_path_sans_ext(basename(plot_file))
  spec <- source(plot_file, local = TRUE)$value

  for (device_name in names(visual_renderers)) {
    test_that(paste0(device_name, ": ", plot_name), {
      skip_if_not_installed("doconv")
      renderer <- visual_renderers[[device_name]]
      renderer$skip()

      png_path <- renderer$render(
        spec$plot,
        width = spec$width %||% 6,
        height = spec$height %||% 6,
        res = 300
      )

      doconv::expect_snapshot_doc(
        name = paste0(device_name, "-", plot_name),
        x = png_path,
        engine = "testthat",
        tolerance = renderer$tolerance %||% 0.001
      )
    })
  }
}
