
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

RGDALSQL
--------

WIP

``` r
library(RGDALSQL)
#> Linking to GDAL 2.2.3, released 2017/11/20
f = system.file("example-data/continents", package = "rgdal2")
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> # A tibble: 1 x 2
#>   CONTINENT GEOM                                                          
#>   <chr>     <chr>                                                         
#> 1 Asia      "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 93.27…


dbSendQuery(db, "SELECT * FROM continent WHERE continent LIKE '%ca'")
#> # A tibble: 4 x 2
#>   CONTINENT     GEOM                                                      
#>   <chr>         <chr>                                                     
#> 1 North America "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ -…
#> 2 Africa        "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 0…
#> 3 South America "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ -…
#> 4 Antarctica    "{ \"type\": \"MultiPolygon\", \"coordinates\": [ [ [ [ 5…
```

Geometry currently is just in JSON form. See hypertidy/vapour for the tooling.
