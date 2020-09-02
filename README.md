
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis-CI Build
Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL)
[![Coverage
Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

## RGDALSQL

WIP

``` r
library(RGDALSQL)
#> Warning: replacing previous import 'vctrs::data_frame' by 'tibble::data_frame'
#> when loading 'dplyr'
f = system.file("extdata/continents", package = "RGDALSQL")
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> Field names: CONTINENT
#> Geometry (1 features): 
#> <MULTIPOLYGON (((93.2755 80.2636, 93.148 80.3139, 91.4249 80.3101...>


dbSendQuery(db, "SELECT * FROM continent WHERE continent LIKE '%ca'")
#> Field names: CONTINENT
#> Geometry (4 features): 
#> <MULTIPOLYGON (((-25.2817 71.3917, -25.6239 71.5372, -26.9503 71.5786...>
#> <MULTIPOLYGON (((0.694651 5.77337, 0.635833 5.94451, 0.506462 6.05859...>
#> <MULTIPOLYGON (((-81.7131 12.4903, -81.7201 12.5453, -81.6924 12.5903...>
#> <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -46.3719...>

(res <- dbReadTable(db, "continent"))
#> # A tibble: 8 x 2
#>   CONTINENT     GEOM                                                            
#>   <chr>         <wk_wkb>                                                        
#> 1 Asia          <MULTIPOLYGON (((93.2755 80.2636, 93.148 80.3139, 91.4249 80.31…
#> 2 North America <MULTIPOLYGON (((-25.2817 71.3917, -25.6239 71.5372, -26.9503 7…
#> 3 Europe        <MULTIPOLYGON (((58.0614 81.6878, 57.8899 81.7099, 59.4355 81.8…
#> 4 Africa        <MULTIPOLYGON (((0.694651 5.77337, 0.635833 5.94451, 0.506462 6…
#> 5 South America <MULTIPOLYGON (((-81.7131 12.4903, -81.7201 12.5453, -81.6924 1…
#> 6 Oceania       <MULTIPOLYGON (((-177.393 28.1842, -177.388 28.2146, -177.361 2…
#> 7 Australia     <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10…
#> 8 Antarctica    <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -4…
```

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
#> # Source:   lazy query [?? x 2]
#> # Database: GDALSQLConnection
#>   CONTINENT GEOM                                                                
#>   <chr>     <wk_wkb>                                                            
#> 1 Australia <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10.145…


tbl(db, "continent") %>% dplyr::filter(continent %in% c("Australia", "Antarctica")) %>% collect() 
#> # A tibble: 2 x 2
#>   CONTINENT  GEOM                                                               
#>   <chr>      <wk_wkb>                                                           
#> 1 Australia  <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10.14…
#> 2 Antarctica <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -46.3…
```

Try OSM PBF.

``` r
# wget https://download.geofabrik.de/europe/albania-latest.osm.pbf
f <- "~/albania-latest.osm.pbf"
pbf <- dbConnect(RGDALSQL::GDALSQL(),f)
## we have to use a normalized path 
## (vapour doesn't do this yet, but GDALSQL will do it *when connecting*, 
## currently maintains the input DSN)
pbf
# db_list_tables(pbf)

tbl(pbf, "points") 
# Source:   table<points> [?? x 11]
# Database: GDALSQLConnection
   osm_id  name      barrier highway   ref   address is_in place man_made other_tags                            GEOM      
   <chr>   <chr>     <chr>   <chr>     <chr> <chr>   <chr> <chr> <chr>    <chr>                                 <wk_wkb>  
 1 154606… ""        ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (1…
 2 154926… ""        ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\""      <POINT (1…
 3 154927… ""        ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (1…
 4 154927… ""        ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\""      <POINT (1…
 5 154928… ""        ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (1…
 6 154936… ""        ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\",\"su… <POINT (1…
 7 268630… "Grykat … ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\""               <POINT (1…
 8 268632… "Kakiuki" ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\""               <POINT (1…
 9 268635… "Mali i … ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\",\"wikidata\"=… <POINT (1…
10 268635… "Maja e … ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\",\"prominence\… <POINT (2…
# … with more rows
```

``` r
f <- "inst/extdata/shapes.gpkg"
conn <- dbConnect(RGDALSQL::GDALSQL(),f)
conn
#> <GDALSQLConnection>
#>   DSN: inst/extdata/shapes.gpkg
dbListTables(conn)
#> [1] "sids"

x <- dbSendQuery(conn, "SELECT * FROM sids WHERE SID74 < 10")
```
