

RGDALSQL_default_options <- list(
  ## weird name, but is the default when none exists aand SQL is executed (otherwise it is "")
  RGDALSQL.default.geom.name = "_ogr_geometry_"
)

.onLoad <- function(libname, pkgname) {
  op <- options()
  toset <- !(names(RGDALSQL_default_options) %in% names(op))
  if (any(toset)) options(RGDALSQL_default_options[toset])

  invisible()
}
