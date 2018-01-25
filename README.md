
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

RGDALSQL
--------

WIP

``` r
library(RGDALSQL)
f = system.file("example-data/continents", package = "rgdal2")
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> Field names: CONTINENT
#> Geometry (1 features): 
#> { "type": "MultiPolygon", "coordinat


dbSendQuery(db, "SELECT * FROM continent WHERE continent LIKE '%ca'")
#> Field names: CONTINENT
#> Geometry (4 features): 
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat
#> { "type": "MultiPolygon", "coordinat
```

Geometry currently is just in JSON form. See hypertidy/vapour for the tooling.
