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
           dbname = "character",
           rgdal2DS = "RGDAL2Datasource"
         )
)


#' dbConnect
#'
#' dbConnect
#'
#' @param drv An object created by \code{GDALSQL()}
#' @export
#' @importFrom rgdal2 openOGR
#' @rdname GDALSQL-dbConnect
#' @examples
#' \dontrun{
#' db <- dbConnect(RGDALSQL::GDALSQL(), afile)
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' chuck <- rgdal::readOGR(afile, "sids") ## bizarrely this resets the problem
#' con <- rgdal2::openOGR(afile)
#' #dbWriteTable(db, "mtcars", mtcars)
#' #dbGetQuery(db, "SELECT * FROM mtcars WHERE cyl == 4")
#' }
setMethod("dbConnect", "GDALSQLDriver",
          function(drv, dbname = "", readonly = TRUE, ...) {
  # ...
  con <- rgdal2::openOGR(dbname)
  new("GDALSQLConnection", host = "", rgdal2DS = con,  ...)
})

#' @rdname GDALSQLConnection-class
#' @export
setMethod("show", "GDALSQLConnection", function(object) {
  cat("<GDALSQLConnection>\n")
 # if (dbIsValid(object)) {
    cat("  Path: ", object@dbname, "\n", sep = "")
    print(object@rgdal2DS)
  #} else {
  #  cat("  DISCONNECTED\n")
  #}
})

## dbDisconnect

 #' GDALSQL results class
 #'
 #' @keywords internal
 #' @export
 setClass("GDALSQLResult",
  contains = "DBIResult",
  ## dummy for now to avoid null pointer error
  slots = list(a = "character")
  )

#' Send a query to GDALSQL.
#'
#' @export
#' @examples
#' f = system.file("example-data/continents", package = "rgdal2")
#' chuck <- rgdal::ogrInfo(f, "continent") ## bizarrely this resets the problem
#' db <- dbConnect(RGDALSQL::GDALSQL(), f)
#' dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
setMethod("dbSendQuery", "GDALSQLConnection",
          function(conn, statement, ...) {
            layer <- rgdal2::getSQLLayer(conn@rgdal2DS, statement)
            print(layer)

            new("GDALSQLResult", ...)
          })
