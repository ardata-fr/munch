.onLoad <- function(libname, pkgname) {
  # methods of munch for the S7 generics of 'ggplot2' (merge_element)
  S7::methods_register()
}
