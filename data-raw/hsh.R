
library(spbabel)
sph <- spbabel::sp(holey)
sph@data <- as.data.frame(sph@data)
sph$ch <- letters[seq(nrow(sph))]
sph@proj4string <- CRS("+proj=laea +lon_0=147 +lat_0=-42 +units=km")
rgdal::writeOGR(sph, "inst/extdata/hsh.gpkg", "hsh", "GPKG", overwrite = TRUE)

## just for laughs
rgdal::writeOGR(sph, "inst/extdata/BNA/hsh.bna", "hsh", "BNA", overwrite = TRUE)

## very funny
## mapview::mapview(sp("inst/extdata/BNA/hsh.bna", crs = proj4string(sph)))
