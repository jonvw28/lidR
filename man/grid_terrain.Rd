% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grid_terrain.r
\name{grid_terrain}
\alias{grid_terrain}
\title{Digital Terrain Model}
\usage{
grid_terrain(.las, res = 1, ...)
}
\arguments{
\item{.las}{LAS objet}

\item{res}{numeric resolution.}

\item{...}{parameters for \link[lidR:lasterrain]{lasterrain}. Select the method and
its parameters for spatial interpolation.}
}
\value{
A RasterLayer from package raster
}
\description{
Interpolate ground points and create a rasterized digital terrain model. The interpolation
is base on \link[lidR:lasterrain]{lasterrain} which provides 3 methods for spatial interpolation:
\code{"knnidw"}, \code{"akima"} and \code{"kriging"}. The algorithm uses the points classified as "ground"
to compute the interpolation. The function forces the original lowest ground point of each
pixel (if it exists) to be chosen instead of the interpolated values.
}
\examples{
LASfile <- system.file("extdata", "Topography.laz", package="lidR")
lidar = readLAS(LASfile)
plot(lidar)

dtm1 = grid_terrain(lidar, method = "knnidw")
dtm2 = grid_terrain(lidar, method = "akima")

raster::plot(dtm1, col = height.colors(50))
raster::plot(dtm2, col = height.colors(50))
plot3d(dtm1)
plot3d(dtm2)

\dontrun{
dtm3 = grid_terrain(lidar, method = "kriging")
raster::plot(dtm3, col = height.colors(50))
}
}
\seealso{
\link[lidR:lasterrain]{lasterrain}
\link[lidR:lasnormalize]{lasnormalize}
\link[raster:raster]{RasterLayer}
}

