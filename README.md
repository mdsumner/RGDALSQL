
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

RGDALSQL
--------

WIP

``` r
library(RGDALSQL)
f = system.file("extdata/continents", package = "RGDALSQL")
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> Field names: CONTINENT
#> Geometry (1 features): 
#> { "type": "MultiPolygon", "coordinat


dbSendQuery(db, "SELECT * FROM continent WHERE continent LIKE '%ca'")
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> Field names: CONTINENT
#> Geometry (4 features): 
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat

res <- dbReadTable(db, "continent")
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
print(res)
#> # A tibble: 8 x 2
#>   CONTINENT     GEOM     
#>   <chr>         <list>   
#> 1 Asia          <chr [1]>
#> 2 North America <chr [1]>
#> 3 Europe        <chr [1]>
#> 4 Africa        <chr [1]>
#> 5 South America <chr [1]>
#> 6 Oceania       <chr [1]>
#> 7 Australia     <chr [1]>
#> 8 Antarctica    <chr [1]>
substr(head(res$GEOM), 1, 200)
#> [1] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 93.275543212890625, 80.26361083984375 ], [ 93.148040771484375, 80.313873291015625 ], [ 91.424911499023438, 80.31011962890625 ], [ 92.604049682617188, 8"
#> [2] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ -25.281669616699219, 71.39166259765625 ], [ -25.623889923095703, 71.537200927734375 ], [ -26.950275421142578, 71.578598022460938 ], [ -27.6938896179199"
#> [3] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 58.061378479003906, 81.687759399414062 ], [ 57.889858245849609, 81.709854125976562 ], [ 59.435546875, 81.819297790527344 ], [ 59.159713745117188, 81.72"
#> [4] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 0.694651007652283, 5.773365020751953 ], [ 0.635833263397217, 5.944513320922852 ], [ 0.506461620330811, 6.058594703674316 ], [ 0.405138850212097, 6.0810"
#> [5] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ -81.713058471679688, 12.490276336669922 ], [ -81.720146179199219, 12.545276641845703 ], [ -81.692367553710938, 12.590276718139648 ], [ -81.690979003906"
#> [6] "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ -177.393341064453125, 28.184158325195312 ], [ -177.387969970703125, 28.214576721191406 ], [ -177.360549926757812, 28.22041130065918 ], [ -177.364578247"
```

Geometry currently is just in JSON form. See hypertidy/vapour for the tooling.

Lazy does not work yet ...

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
tbl(db, "continent") %>% dplyr::filter(continent == "Australia")
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate

#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> # Source:   lazy query [?? x 2]
#> # Database: GDALSQLConnection
#>   CONTINENT GEOM     
#>   <chr>     <list>   
#> 1 Australia <chr [1]>

library(sf)
#> Linking to GEOS 3.5.1, GDAL 2.2.2, proj.4 4.9.2
to_sf <- function(x, ...) {
  x[["GEOM"]] <- sf::st_as_sfc(x[["GEOM"]], GeoJSON = TRUE)
  sf::st_as_sf(x)
}
tbl(db, "continent") %>% dplyr::filter(continent %in% c("Australia", "Antarctica")) %>% collect() %>% 
  to_sf()
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate

#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> Simple feature collection with 2 features and 1 field
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: -180 ymin: -90 xmax: 180 ymax: -10.14556
#> epsg (SRID):    4326
#> proj4string:    +proj=longlat +datum=WGS84 +no_defs
#> # A tibble: 2 x 2
#>   CONTINENT                                                           GEOM
#>   <chr>                                                 <MULTIPOLYGON [°]>
#> 1 Australia  (((142.28 -10.26556, 142.1894 -10.20417, 142.2286 -10.14556,…
#> 2 Antarctica (((51.80305 -46.45667, 51.71055 -46.44667, 51.65374 -46.3719…
```

Try OSM PBF.

``` r
f <- "~/albania-latest.osm.pbf"
pbf <- dbConnect(RGDALSQL::GDALSQL(),f)
## we have to use a normalized path 
## (vapour doesn't do this yet, but GDALSQL will do it *when connecting*, 
## currently maintains the input DSN)
pbf
#> <GDALSQLConnection>
#>   DSN: ~/albania-latest.osm.pbf
# db_list_tables(pbf)

tbl(pbf, "points") 
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate

#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> # Source:   table<points> [?? x 11]
#> # Database: GDALSQLConnection
#>    osm_id  name      barrier highway    ref   address is_in place man_made
#>    <chr>   <chr>     <chr>   <chr>      <chr> <chr>   <chr> <chr> <chr>   
#>  1 154606… ""        ""      traffic_s… ""    ""      ""    ""    ""      
#>  2 154927… ""        ""      traffic_s… ""    ""      ""    ""    ""      
#>  3 154928… ""        ""      traffic_s… ""    ""      ""    ""    ""      
#>  4 268630… Grykat E… ""      ""         ""    ""      ""    ""    ""      
#>  5 268632… Kakiuki   ""      ""         ""    ""      ""    ""    ""      
#>  6 268635… Mali i D… ""      ""         ""    ""      ""    ""    ""      
#>  7 268635… Maja e D… ""      ""         ""    ""      ""    ""    ""      
#>  8 268635… Maja e D… ""      ""         ""    ""      ""    ""    ""      
#>  9 268635… Maja e D… ""      ""         ""    ""      ""    ""    ""      
#> 10 268635… Maja e D… ""      ""         ""    ""      ""    ""    ""      
#> # ... with more rows, and 2 more variables: other_tags <chr>, GEOM <list>
```

``` r
f <- "inst/extdata/shapes.gpkg"
conn <- dbConnect(RGDALSQL::GDALSQL(),f)
conn
#> <GDALSQLConnection>
#>   DSN: inst/extdata/shapes.gpkg
dbListTables(conn)
#> [1] "sids"

x <- dbSendQuery(conn, "SELECT AREA FROM sids WHERE SID74 < 10")
#> Warning in fid_select(sql): select statement assumed, modified to 'SELECT
#> FID FROM' boilerplate
#> Warning in vapour_read_geometry_cpp(dsource = dsource, layer = layer, sql = sql, : at least one geometry is NULL, perhaps the 'sql' argument excludes the native geometry?
#> (use 'SELECT * FROM ..')
```
