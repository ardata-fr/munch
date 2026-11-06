library(gdtools)

font_set_liberation()
# a fixed font: text widths, so lines, must not depend on the machine
flextable::set_flextable_defaults(font.family = "Liberation Sans")

# Open a ragg capture device for testing
# This is necessary because ggplotGrob() can trigger device creation
# and munch requires a systemfonts-compatible device
ragg::agg_capture()
