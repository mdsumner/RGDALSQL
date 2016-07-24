#' Driver for GDAL SQL.
#'
#' @keywords internal
#' @export
#' @import DBI
#' @import methods
setClass("GDALSQLDriver", contains = "DBIDriver")

#' @export
#' @rdname GDALSQLDriver-class
setMethod("dbUnloadDriver", "GDALSQLDriver", function(drv, ...) {
  TRUE
})
#> [1] "dbUnloadDriver"


setMethod("show", "GDALSQLDriver", function(object) {
  cat("<GDALSQLDriver>\n")
})

#' @export
GDALSQL <- function() {
  new("GDALSQLDriver")
}


#' GDALSQL connection class.
#'
#' @export
#' @keywords internal
setClass("GDALSQLConnection",
         contains = "DBIConnection",
         slots = list(
           host = "character",
           username = "character",
           # and so on
           ptr = "externalptr"
         )
)


#' @param drv An object created by \code{GDALSQL()}
#' @export
#' @importFrom rgdal2 openOGR
#' @rdname GDALSQL
#' @examples
#' \dontrun{
#' db <- dbConnect(RGDALSQL::GDALSQL())
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' #dbWriteTable(db, "mtcars", mtcars)
#' #dbGetQuery(db, "SELECT * FROM mtcars WHERE cyl == 4")
#' }
setMethod("dbConnect", "GDALSQLDriver",
          function(drv, dsn = "", ...) {
  # ...

  new("GDALSQLConnection", host = host, ...)
})
