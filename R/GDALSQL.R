#' Driver for GDAL SQL.
#'
#' @keywords internal
#' @export
#' @import DBI
#' @import methods
setClass("GDALSQLDriver", contains = "DBIDriver")

#setOldClass("tbl_df")




#' @export
#' @rdname GDALSQLDriver-class
setMethod("dbUnloadDriver", "GDALSQLDriver", function(drv, ...) {
  TRUE
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
           DSN = "character"
         )
)

#' @rdname GDALSQLConnection-class
#' @export
setMethod("show", "GDALSQLConnection", function(object) {
  cat("<GDALSQLConnection>\n")
  cat("  DSN: ", object@DSN, "\n", sep = "")
})


#' dbConnect
#'
#' dbConnect
#'
#' @param drv GDALSQLDriver
#' @param DSN  data source name, may be a file, or folder path, database connection string, or URL
#' @param readonly open in readonly mode?
#' @export
#' @rdname GDALSQL
#' @examples
#' \dontrun{
#' ## this is a nothing connection
#' db <- dbConnect(RGDALSQL::GDALSQL())
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' db <- dbConnect(RGDALSQL::GDALSQL(), afile)
#' dbSendQuery(db, "SELECT * FROM sids")
#' }
setMethod("dbConnect", "GDALSQLDriver",
          function(drv, DSN = "", readonly = TRUE, ...) {

  new("GDALSQLConnection", host = "", DSN = DSN,  ...)
})
#' @export
setMethod("show", "GDALSQLDriver", function(object) {
  cat("<GDALSQLDriver>\n")
  cat(object@DSN)
})
#' @export
setMethod("dbDisconnect", "GDALSQLDriver",
          function(conn, ...) {
  conn@DSN <- ""
  conn
})


 #' GDALSQL results class
 #'
 #' @keywords internal
 #' @export
 setClass("GDALSQLResult",
  contains = "DBIResult",
  slots = c(layer_data = "list", layer_geom = "list")
  )

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

            new("GDALSQLResult",
                layer_data = layer_data,
                layer_geom = as.list(layer_geom))
          })


#' @export
setMethod("dbClearResult", "GDALSQLResult", function(res, ...) {
  res@layer <- NULL
  TRUE
})
setMethod("show", "GDALSQLResult",
          function(object) {
            cat(sprintf("Field names: %s\n",
                        paste(names(object@layer_data), collapse = ", ")))
            cat(sprintf("Geometry (%i features): \n%s",
                        length(object@layer_geom),
                        paste(substr(head(object@layer_geom), 1, 36), collapse = "\n")))
            invisible(NULL)
          })
#' Retrieve records from GDALSQL query
#' @export
setMethod("dbFetch", "GDALSQLResult", function(res, n = -1, ...) {
  layer <- tibble::as_tibble(res@layer_data)
  layer[["GEOM"]] <- res@layer_geom
  layer
})


#' @export
setMethod("dbHasCompleted", "GDALSQLResult", function(res, ...) {
  TRUE
})



#' @export
setMethod("dbReadTable", c(conn = "GDALSQLConnection", name = "character"),
          function(conn, name, ...){
            x <- dbSendQuery(conn, sprintf("SELECT * FROM %s", name))
            dbFetch(x)
          })


