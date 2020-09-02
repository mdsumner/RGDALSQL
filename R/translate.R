#' @export
#' @importFrom dplyr db_query_fields
db_query_fields.GDALSQLConnection <- function(con, sql, ...) {
  sql <- sql_select(con, sql("*"), sql_subquery(con, sql),  limit = 1)
  qry <- dbSendQuery(con, sql)
  on.exit(dbClearResult(qry))

  res <- dbFetch(qry, 0)
  names(res)
}
