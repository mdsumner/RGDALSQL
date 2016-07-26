#devtools::install_github("edzer/rgdal2")

#' Flatten rgdal2 vector lists
#'
#' Create tibbles from rgdal2 raw read, for any geometry (x-y, x-y-z, x-y-z-m, x-y-m).
#'
#' Modelled on sf::ST_read, which calls this flatten and returns matrices.
#' @param x list as returned by rgdal2::getPoints(x, nested = TRUE)
#' @noRd
flatter <-  function(x) {
  if (all(c("x", "y") %in% names(x))) { # we're at the deepest level
    setNames(as_tibble(x), c("x_", "y_"))
  } else {
    lapply(x, flatten)
  }
}

#' Read a single object.
#'
#' Read from a vector layer, returns a single object by (counting) ID.
#'
#' Flattened to nested list of tibbles. sf calls this "readFeature", and returns matrices.
#' @param layer OGRLayer from rgdal2
#' @param id zero based object ID
#'
#' @noRD
readObject <- function(layer, id) {
  ft = rgdal2::getFeature(layer, id)
  geom = rgdal2::getGeometry(ft)
  flatter(rgdal2::getPoints(geom, nested = TRUE))
}

#' Read raw rgdal2 output.
#'
#' Read a list of the geometry and the object metadata as nested lists.
#' Includes a `meta` table to store the CRS string/s, the source name/s, plus future stuff.
#'
#' sf processes this all in-place into R level simple feature classes.
#'
#' @param x data source name (e.g. a file, or a database connection string)
#' @param layer a layer name from the data source, or a 1-based index of those
#'
read_rgdal <- function(x, layer = 1L) {
  if (!requireNamespace("rgdal2", quietly = TRUE))
    stop("package rgdal2 required for this function; try devtools::install_github(\"edzer/rgdal2\")")
  rgdal2::l
  o <- rgdal2::openOGRLayer(x, layer)
  ids <- rgdal2::getIDs(o)
  srs <- rgdal2::getSRS(o)
  if (is.null(srs)) srs <- ""
  p4s <- if (nchar(srs) < 1L)  as.character(NA) else rgdal2::getPROJ4(srs)
  geom <- lapply(ids, function(id) readObject(o, id))
  metadata <- lapply(ids, function(id) rgdal2::getFields(rgdal2::getFeature(o, id)))
  ## TODO layer should be the layername, not the convenient index for the first one
  meta <- tibble(srs = srs, p4s = p4s, dsn = x, layer = layer)
 list(rawgeom = geom, rawdata = metadata, meta = meta)
}
#' simplification of sf::read.sf to avoid classes
#' need to return the data_data still
read_tables <- function(x, layer = 1L) {
  rgdalraw <- read_rgdal(x, layer = layer)
  geomtab <- bind_rows(lapply(rgdalraw$rawgeom, function(y) bind_rows(lapply(y, bind_rows, .id = "simple_feature"), .id = "part")), .id = "object_")
  geomtab <- mutate(geomtab, branch_ = paste("o", object_, "p", part, "r", simple_feature, sep = "_"), island_ = simple_feature == 1, x_ = x, y_ = y, order_ = row_number(), simple_feature = NULL)
  metatab <- bind_rows(rgdalraw$rawdata)
  ## now we can build sp, sf, ggplot2, or gris
  list(geom = geomtab, data = metatab)
}


sp.character <- function(x, layer = 1L, crs = "", ...) {
  tables <- read_tables(x, layer)
  if (nchar(crs) == 0L) crs <- tables$meta$p4s
  spbabel::sp(tables$geom, tables$data, crs = crs)
}

