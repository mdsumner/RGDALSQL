
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/RGDALSQL.svg?branch=master)](https://travis-ci.org/mdsumner/RGDALSQL) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/RGDALSQL/master.svg)](https://codecov.io/github/mdsumner/RGDALSQL?branch=master)

RGDALSQL
--------

Not much yet. `rgdal2` is still a little fragile, also read only for drawings, and I'm mostly out of my depth there.

``` r
library(RGDALSQL)
f = system.file("example-data/continents", package = "rgdal2")
chuck <- rgdal::ogrInfo(f, "continent") ## bizarrely this prevents this problem:
##https://github.com/thk686/rgdal2/issues/7
db <- dbConnect(RGDALSQL::GDALSQL(), f)
dbSendQuery(db, "SELECT * FROM continent WHERE FID < 1")
#> INFO: Open of `/perm_storage/home/mdsumner/R/x86_64-pc-linux-gnu-library ... 
#>       using driver `ESRI Shapefile' successful. 
#>  
#> Layer name: continent 
#> Geometry: Polygon 
#> Feature Count: 1 
#> Extent: (-180.000000, -90.000000) - (180.000000, 83.602203) 
#> Layer SRS WKT: 
#> GEOGCS["WGS 84", 
#>     DATUM["WGS_1984", 
#>         SPHEROID["WGS 84",6378137,298.257223563, 
#>             AUTHORITY["EPSG","7030"]], 
#>         AUTHORITY["EPSG","6326"]], 
#>     PRIMEM["Greenwich",0, 
#>         AUTHORITY["EPSG","8901"]], 
#>     UNIT["degree",0.0174532925199433, 
#>         AUTHORITY["EPSG","9122"]], 
#>     AUTHORITY["EPSG","4326"]] 
#> Geometry Column = _ogr_geometry_ 
#> CONTINENT: String (13.0)
#> <GDALSQLResult>
```

That's only printing out a SQL layer summary for now, need to use the spbabel/gris approach to get the metadata/geometry, perhaps in spbabel form. From there we can feed to other structures and formats.
