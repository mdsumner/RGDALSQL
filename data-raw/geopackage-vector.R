library(rgdal2)

ds <- system.file("shapes", package = "maptools")
system(sprintf("ogr2ogr data-raw/shapes.gpkg %s sids -f GPKG", ds))

file.copy("data-raw/shapes.gpkg",  "inst/extdata/shapes.gpkg")
file.remove("data-raw/shapes.gpkg")

## creation ok but writing layers with rgdal2 is not yet possible
##
# layer <- openOGRLayer(system.file("shapes", package = "maptools"))
#
# newDS <- newOGRDatasource(driver = "GPKG", fname = "data-raw/shapes.gpkg",
#                           opts = character())
# sx <- addLayer(newDS,
#          lyrname = getLayerName(layer),
#          geomType = "Polygon", # rgdal2::getGeometryType(layer),
#          srs = getSRS(layer),
#          opts = character())
#
#
#
# dataset <- openOGR(system.file("shapes", package = "maptools"))
# copyDataset(dataset, file = "data-raw/shapes.gpkg", driver = "GPKG",
#             opts = character())
