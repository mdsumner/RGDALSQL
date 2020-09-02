#' Driver for GDAL SQL.
#'
#' @keywords internal
#' @export
#' @import DBI
#' @import methods
setClass("GDALSQLDriver", contains = "DBIDriver")

#setOldClass("tbl_df")
setOldClass(c("wk_wkb", "wk_vctr"))
setOldClass(c("wk_wkt", "wk_vctr"))



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

            #DSN <- normalizePath(DSN, mustWork = FALSE)
  new("GDALSQLConnection", host = "", DSN = DSN,  ...)
})
#' @export
setMethod("show", "GDALSQLDriver", function(object) {
  cat("<GDALSQLDriver>\n")
})
#' @export
setMethod("dbDisconnect", "GDALSQLConnection",
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
  slots = c(layer_data = "list", layer_geom = "wk_vctr")
  )

#' Send a query to GDALSQL.
#'
#' @param conn database connection, s created by \code{\link{dbConnect}}
#' @param statement OGR SQL, see http://www.gdal.org/ogr_sql.html
#' @param ... for compatibility with generic
#' @export
#' @importFrom vapour vapour_read_attributes vapour_read_geometry_text
#' @importFrom wk new_wk_wkb
#' @examples
#' afile <- system.file("extdata", "shapes.gpkg", package = "RGDALSQL")
#' db <- dbConnect(RGDALSQL::GDALSQL(), afile)
#' dbSendQuery(db, "SELECT * FROM sids WHERE FID < 1")
setMethod("dbSendQuery", "GDALSQLConnection",
          function(conn, statement, ...) {
            ## FIXME: may not be a file
            DSN <- normalizePath(conn@DSN, mustWork = FALSE)

            layer_data <- vapour::vapour_read_attributes(DSN, sql = statement)
            layer_geom <- wk::new_wk_wkb(vapour::vapour_read_geometry(DSN, sql = statement))

            new("GDALSQLResult",
                layer_data = layer_data,
                layer_geom = layer_geom)

          })


#' @export
setMethod("dbClearResult", "GDALSQLResult", function(res, ...) {
  #res@layer_data <- NULL
  #res@layer_geom <- NULL
  #res <- NULL
  TRUE
})
#' @importFrom utils head
#' @export
setMethod("show", "GDALSQLResult",
          function(object) {
            cat(sprintf("Field names: %s\n",
                        paste(names(object@layer_data), collapse = ", ")))
            cat(sprintf("Geometry (%i features): \n%s",
                        length(object@layer_geom),
                        paste(utils::head(object@layer_geom), collapse = "\n")))
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


#' @importFrom vapour vapour_layer_names
#' @export
setMethod("dbListTables", c(conn = "GDALSQLConnection"),
          function(conn, ...){
            x <- vapour::vapour_layer_names(conn@DSN)
          })

#' @export
setMethod("dbExistsTable", c(conn = "GDALSQLConnection"),
          function(conn, name, ...){
            name %in% dbListTables(conn)
          })

#' @export
setMethod("dbDataType", "GDALSQLDriver", function(dbObj, obj, ...) {
  ## see "type of the fields" http://www.gdal.org/ogr_sql.html
##  vapour::vapour_read_attributes(normalizePath(f), sql = "SELECT CAST(osm_id AS integer(8)) AS OSM_ FROM points LIMIT 1")
  if (is.factor(obj)) return("character")
  if (is.data.frame(obj)) return(callNextMethod(dbObj, obj))

  switch(typeof(obj),
         logical = "boolean",
         character = "character",
         double = "numeric",
         integer = "integer",
         list = "character",
         raw = "character",
         blob = "character",
         stop("Unsupported type", call. = FALSE)
  )
  }


        )
#' @export
setMethod("dbGetInfo", "GDALSQLDriver",
          function(dbObj, ...) {
   list(name = "GDALSQLDriver",
        note = "virtual SQL driver for GDAL",
        driver.version = "0.0.1.9001",
        client.version = "0.0.1.9001")
})



