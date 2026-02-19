library(gdtools)

font_set_liberation()

# Open a ragg capture device for testing
# This is necessary because ggplotGrob() can trigger device creation
# and munch requires a systemfonts-compatible device
ragg::agg_capture()
