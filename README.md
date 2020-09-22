
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
#>   CONTINENT     `_ogr_geometry_`                                                
#>   <chr>         <wk_wkb>                                                        
#> 1 North America <MULTIPOLYGON (((-25.2817 71.3917, -25.6239 71.5372, -26.9503 7…
#> 2 Africa        <MULTIPOLYGON (((0.694651 5.77337, 0.635833 5.94451, 0.506462 6…
#> 3 South America <MULTIPOLYGON (((-81.7131 12.4903, -81.7201 12.5453, -81.6924 1…
#> 4 Antarctica    <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -4…

(res <- dbReadTable(db, "continent"))
#> # A tibble: 8 x 2
#>   CONTINENT     `_ogr_geometry_`                                                
#>   <chr>         <wk_wkb>                                                        
#> 1 Asia          <MULTIPOLYGON (((93.2755 80.2636, 93.148 80.3139, 91.4249 80.31…
#> 2 North America <MULTIPOLYGON (((-25.2817 71.3917, -25.6239 71.5372, -26.9503 7…
#> 3 Europe        <MULTIPOLYGON (((58.0614 81.6878, 57.8899 81.7099, 59.4355 81.8…
#> 4 Africa        <MULTIPOLYGON (((0.694651 5.77337, 0.635833 5.94451, 0.506462 6…
#> 5 South America <MULTIPOLYGON (((-81.7131 12.4903, -81.7201 12.5453, -81.6924 1…
#> 6 Oceania       <MULTIPOLYGON (((-177.393 28.1842, -177.388 28.2146, -177.361 2…
#> 7 Australia     <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10…
#> 8 Antarctica    <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -4…

dplyr::tbl(db, "continent")
#> # Source:   table<continent> [?? x 2]
#> # Database: GDALSQLConnection
#>   CONTINENT     `_ogr_geometry_`                                                
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
  - no sub-queryies in non-DB drivers (i.e. no collapse for SHP or GDB)

filter, arrange, summarize, transmute, mutate, ok but cannot be chained
for nested sub-queries

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
#>   CONTINENT `_ogr_geometry_`                                                    
#>   <chr>     <wk_wkb>                                                            
#> 1 Australia <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10.145…


tbl(db, "continent") %>% dplyr::filter(continent %in% c("Australia", "Antarctica")) %>% collect() 
#> # A tibble: 2 x 2
#>   CONTINENT  `_ogr_geometry_`                                                   
#>   <chr>      <wk_wkb>                                                           
#> 1 Australia  <MULTIPOLYGON (((142.28 -10.2656, 142.189 -10.2042, 142.229 -10.14…
#> 2 Antarctica <MULTIPOLYGON (((51.8031 -46.4567, 51.7106 -46.4467, 51.6537 -46.3…
```

Try OSM PBF.

``` r
# wget https://download.geofabrik.de/europe/albania-latest.osm.pbf
f <- fs::path_expand("~/albania-latest.osm.pbf")
pbf <- dbConnect(RGDALSQL::GDALSQL(),f)
## we have to use a normalized path 
## (vapour doesn't do this yet, but GDALSQL will do it *when connecting*, 
## currently maintains the input DSN)
pbf
# db_list_tables(pbf)

tbl(pbf, "points") 
# Source:   table<points> [?? x 11]
# Database: GDALSQLConnection
   osm_id  name     barrier highway   ref   address is_in place man_made other_tags                            `_ogr_geometry_`  
   <chr>   <chr>    <chr>   <chr>     <chr> <chr>   <chr> <chr> <chr>    <chr>                                 <wk_wkb>          
 1 154606… ""       ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (19.8082 4…
 2 154926… ""       ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\""      <POINT (19.4762 4…
 3 154927… ""       ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (19.8221 4…
 4 154927… ""       ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\""      <POINT (19.5045 4…
 5 154928… ""       ""      "traffic… ""    ""      ""    ""    ""       "\"crossing\"=>\"traffic_signals\",\… <POINT (19.8081 4…
 6 154936… ""       ""      "crossin… ""    ""      ""    ""    ""       "\"crossing\"=>\"uncontrolled\",\"su… <POINT (19.4954 4…
 7 268630… "Grykat… ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\""               <POINT (19.9047 4…
 8 268632… "Kakiuk… ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\""               <POINT (19.8792 4…
 9 268635… "Mali i… ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\",\"wikidata\"=… <POINT (19.9241 4…
10 268635… "Maja e… ""      ""        ""    ""      ""    ""    ""       "\"natural\"=>\"peak\",\"prominence\… <POINT (20.1628 4…
# … with more rows

tbl(pbf, "multipolygons") %>% filter(osm_id == "53292") %>% select(`_ogr_geometry_`, type)
# Source:   lazy query [?? x 2]
# Database: GDALSQLConnection
  type     `_ogr_geometry_`                                                      
  <chr>    <wk_wkb>                                                              
1 boundary <MULTIPOLYGON (((20.0126 42.5258, 20.0124 42.5257, 20.0123 42.5258...>
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

tbl(conn, "sids") %>% 
  arrange(desc(AREA))  %>% 
  transmute(a = AREA *8, geom, AREA) %>% 
  filter(a > 1.62)  %>% 
  show_query()
#> <SQL>
#> Warning: Ignoring sort order.
#> Hint: `arrange()` only has an effect if used at the end of a pipe or immediately before `head()`. See `?arrange.tbl_lazy` for details.
#> SELECT *
#> FROM (SELECT "AREA" * 8.0 AS "a", "geom", "AREA"
#> FROM "sids") "dbplyr_001"
#> WHERE ("a" > 1.62)


## with SHP we can't do subquery
f <- system.file("shape/nc.shp", package = "sf")
conn <- dbConnect(GDALSQL(), f)
## but the special variables are there
tbl(conn, "nc") %>% arrange(OGR_GEOM_AREA)
#> # Source:     table<nc> [?? x 15]
#> # Database:   GDALSQLConnection
#> # Ordered by: OGR_GEOM_AREA
#>     AREA PERIMETER CNTY_ CNTY_ID NAME  FIPS  FIPSNO CRESS_ID BIR74 SID74 NWBIR74
#>    <dbl>     <dbl> <dbl>   <dbl> <chr> <chr>  <dbl>    <int> <dbl> <dbl>   <dbl>
#>  1 0.042     0.999  2238    2238 New … 37129  37129       65  5526    12    1633
#>  2 0.044     1.16   1887    1887 Chow… 37041  37041       21   751     1     368
#>  3 0.051     1.10   2109    2109 Clay  37043  37043       22   284     0       1
#>  4 0.053     1.17   1848    1848 Pasq… 37139  37139       70  1638     3     622
#>  5 0.059     1.32   1927    1927 Mitc… 37121  37121       61   671     0       1
#>  6 0.06      1.04   2071    2071 Polk  37149  37149       75   533     1      95
#>  7 0.061     1.23   1827    1827 Alle… 37005  37005        3   487     0      10
#>  8 0.062     1.55   1834    1834 Camd… 37029  37029       15   286     0     115
#>  9 0.063     1      1881    1881 Perq… 37143  37143       72   484     1     230
#> 10 0.064     1.21   1892    1892 Avery 37011  37011        6   781     0       4
#> # … with more rows, and 4 more variables: BIR79 <dbl>, SID79 <dbl>,
#> #   NWBIR79 <dbl>, `_ogr_geometry_` <wk_wkb>
tbl(conn, "nc") %>% arrange(OGR_GEOM_AREA, FID) %>% show_query()
#> <SQL>
#> SELECT *
#> FROM "nc"
#> ORDER BY "OGR_GEOM_AREA", "FID"

## FAILS because subquery
tbl(conn, "nc") %>% mutate(aa = AREA) %>% transmute(a1 = FID) %>% show_query()
#> <SQL>
#> SELECT "FID" AS "a1"
#> FROM (SELECT "AREA", "PERIMETER", "CNTY_", "CNTY_ID", "NAME", "FIPS", "FIPSNO", "CRESS_ID", "BIR74", "SID74", "NWBIR74", "BIR79", "SID79", "NWBIR79", "_ogr_geometry_", "AREA" AS "aa"
#> FROM "nc") "dbplyr_002"

## ok because a single statement
tbl(conn, "nc") %>% transmute(a1 = FID, aa = AREA) %>% collect()
#> # A tibble: 100 x 3
#>       a1    aa `_ogr_geometry_`                                                 
#>    <int> <dbl> <wk_wkb>                                                         
#>  1     0 0.114 <POLYGON ((-81.4728 36.2344, -81.5408 36.2725, -81.562 36.2736..…
#>  2     1 0.061 <POLYGON ((-81.2399 36.3654, -81.2407 36.3794, -81.2628 36.405..…
#>  3     2 0.143 <POLYGON ((-80.4563 36.2426, -80.4764 36.2547, -80.5369 36.2567.…
#>  4     3 0.07  <MULTIPOLYGON (((-76.009 36.3196, -76.0173 36.3377, -76.0329 36.…
#>  5     4 0.153 <POLYGON ((-77.2177 36.241, -77.2346 36.2146, -77.2986 36.2115..…
#>  6     5 0.097 <POLYGON ((-76.7451 36.2339, -76.9807 36.2302, -76.9948 36.2356.…
#>  7     6 0.062 <POLYGON ((-76.009 36.3196, -75.9572 36.1938, -75.9813 36.1697..…
#>  8     7 0.091 <POLYGON ((-76.5625 36.3406, -76.6042 36.315, -76.6482 36.3153..…
#>  9     8 0.118 <POLYGON ((-78.3088 36.26, -78.2829 36.2919, -78.3213 36.5455...>
#> 10     9 0.124 <POLYGON ((-80.0257 36.2502, -80.453 36.2571, -80.4353 36.551...>
#> # … with 90 more rows
```
