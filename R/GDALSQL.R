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

#' GDALSQL
#'
#' GDALSQL driver
#' @export
GDALSQL <- function() {
  new("GDALSQLDriver")
}


#' GDALSQL connection class.
#' @rdname GDALSQLConnection-class
#' @export
#' @keywords internal
setClass("GDALSQLConnection",
         contains = "DBIConnection",
         slots = list(
           host = "character",
           username = "character",
           dbname = "character",
           DSN = "character"
         )
)


#' dbConnect
#'
#' dbConnect
#'
#' @param drv GDALSQLDriver
#' @param dbname data source name, file, or folder path
#' @param readonly open in readonly mode?
#' @export
#' @importFrom rgdal2 openOGR
#' @rdname GDALSQL-dbConnect
#' @examples
#' \dontrun{
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' db <- dbConnect(RGDALSQL::GDALSQL(), afile)
#' chuck <- rgdal::readOGR(afile, "sids") ## bizarrely this resets the problem
#' con <- rgdal2::openOGR(afile)
#' #dbWriteTable(db, "mtcars", mtcars)
#' #dbGetQuery(db, "SELECT * FROM mtcars WHERE cyl == 4")
#' }
setMethod("dbConnect", "GDALSQLDriver",
          function(drv, dbname = "", readonly = TRUE, ...) {
  # ...
  #con <- rgdal2::openOGR(dbname, readonly = readonly)
  new("GDALSQLConnection", host = "", DSN = dbname,  ...)
})

#' @rdname GDALSQLConnection-class
#' @export
setMethod("show", "GDALSQLConnection", function(object) {
  cat("<GDALSQLConnection>\n")
 # if (dbIsValid(object)) {
    cat("  Path: ", object@dbname, "\n", sep = "")
    print(object@DSN)
  #} else {
  #  cat("  DISCONNECTED\n")
  #}
})

## dbDisconnect

setOldClass("tbl_df")
 #' GDALSQL results class
 #'
 #' @keywords internal
 #' @export
 setClass("GDALSQLResult",
  contains = "DBIResult",
  slots = list(layer = "tbl_df")
  )
setMethod("show", "GDALSQLResult",
          function(object) {
          print(object@layer)
            })
#' Send a query to GDALSQL.
#'
#' @param conn database connection, s created by \code{\link{dbConnect}}
#' @param statement OGR SQL, see http://www.gdal.org/ogr_sql.html
#' @param ... for compatibility with generic
#' @export
#' @examples
#' #f = system.file("example-data/continents", package = "rgdal2")
#' #chuck <- rgdal::ogrInfo(f, "continent") ## bizarrely this resets the problem
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' db <- dbConnect(RGDALSQL::GDALSQL(), afile)
#' dbSendQuery(db, "SELECT * FROM sids WHERE FID < 1")
setMethod("dbSendQuery", "GDALSQLConnection",
          function(conn, statement, ...) {

            layer_data <- vapour::vapour_read_attributes(conn@DSN, sql = statement)
            layer_geom <- vapour::vapour_read_geometry_text(conn@DSN, sql = statement)
            layer_data <- tibble::as_tibble(layer_data)
            layer_data[["GEOM"]] <- layer_geom
            #layer <- rgdal2::getSQLLayer(conn@rgdal2DS, statement)
            #print(layer)

            new("GDALSQLResult",
                layer = layer_data)
          })
