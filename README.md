
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

res <- dbReadTable(db, "continent")
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
