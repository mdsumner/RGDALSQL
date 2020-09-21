
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Travis-CI Build
Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL)
[![Coverage
Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

## RGDALSQL

WIP

``` r
library(RGDALSQL)
f = system.file("extdata/continents", package = "RGDALSQL")
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> Field names: CONTINENT
#> Geometry (1 features): 
#> <MULTIPOLYGON (((93.2755 80.2636, 93.148 80.3139, 91.4249 80.3101...>


res <- dbSendQuery(db, "SELECT * FROM continent WHERE continent LIKE '%ca'")
dbFetch(res)
#> # A tibble: 4 x 2
#>   CONTINENT     GEOM                                                            
#>   <chr>         <wk_wkb>                                                        
#> 1 North America <MULTIPOLYGON (((-25.2817 71.3917, -25.6239 71.5372, -26.9503 7…
#> 2 Africa        <MULTIPOLYGON (((0.694651 5.77337, 0.635833 5.94451, 0.506462 6…
#> 3 South America <MULTIPOLYGON (((-81.7131 12.4903, -81.7201 12.5453, -81.6924 1…
#> 4 Antarctica    <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -4…

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

## Limitations

  - currently read-only, so no temporary tables for `compute()`
  - no temporary tables in non-DB drivers (i.e. GPKG is ok, SHP is not)
  - no sub-queryies in non-DB drivers (i.e. no collapse for SHP)

filter, arrange, summarize, transmute, mutate, ok

TODO

  - remove default keep of geometry
  - …

<!-- end list -->

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
#>    DSN: inst/extdata/shapes.gpkg
#> tables: sids
dbListTables(conn)
#> [1] "sids"

x <- dbSendQuery(conn, "SELECT * FROM sids WHERE SID74 < 10")

## atm we must include 'GEOM' if a select wouldn't include it
conn
#> <GDALSQLConnection>
#>    DSN: inst/extdata/shapes.gpkg
#> tables: sids

## we can work with FID but not OGR_GEOM_AREA it seems, and can't select FID ...
tbl(conn, "sids") %>% arrange(desc(FID))  %>% select(BIR74, NAME, GEOM)  %>% collect()
#> # A tibble: 100 x 3
#>    BIR74 NAME       GEOM                                                        
#>    <dbl> <chr>      <wk_wkb>                                                    
#>  1  2181 Brunswick  <POLYGON ((-78.6557 33.9487, -78.6347 33.978, -78.6303 34.0…
#>  2  5526 New Hanov… <POLYGON ((-77.9607 34.1892, -77.9659 34.2423, -77.9753 34.…
#>  3  3350 Columbus   <POLYGON ((-78.6557 33.9487, -79.0745 34.3046, -79.0409 34.…
#>  4  1228 Pender     <POLYGON ((-78.0259 34.3288, -78.1302 34.3641, -78.1548 34.…
#>  5  1782 Bladen     <POLYGON ((-78.2615 34.3948, -78.329 34.3644, -78.4379 34.3…
#>  6  2414 Carteret   <MULTIPOLYGON (((-77.149 34.7643, -77.1643 34.7745, -77.159…
#>  7  7889 Robeson    <POLYGON ((-78.8645 34.4772, -78.9195 34.4536, -78.9507 34.…
#>  8 11158 Onslow     <POLYGON ((-77.5386 34.457, -77.5763 34.4693, -77.6898 34.7…
#>  9  2255 Scotland   <POLYGON ((-79.456 34.6341, -79.6675 34.8007, -79.686 34.80…
#> 10  5868 Craven     <MULTIPOLYGON (((-76.8976 35.2516, -76.9474 35.217, -76.966…
#> # … with 90 more rows

## with SHP we can do arrange but not select on OGR_GEOM_AREA
#f <- system.file("shape/nc.shp", package = "sf")
#tbl(conn, "nc") %>% arrange(desc(OGR_GEOM_AREA))    %>% collect()
```
