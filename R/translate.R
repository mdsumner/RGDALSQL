#' @export
#' @importFrom dplyr db_query_fields
db_query_fields.GDALSQLConnection <- function(con, sql, ...) {
  sql <- dplyr::sql_select(con, dplyr::sql("*"), sql,  limit = 1)

  qry <- DBI::dbSendQuery(con, sql)
  on.exit(DBI::dbClearResult(qry))

  res <- dbFetch(qry, 0)
# browser()
#   res <- vapour::vapour_report_attributes(con@DSN, sql = sql)
#   geom <- vapour::vapour_geom_name(con@DSN, sql = sql)
#   if (nchar(geom) < 1) geom <- getOption("RGDALSQL.default.geom.name")
#   c(names(res), geom)
  names(res)
}
