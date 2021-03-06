% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grid_density.r
\name{grid_density}
\alias{grid_density}
\title{Pulse density surface model}
\usage{
grid_density(.las, res = 4)
}
\arguments{
\item{.las}{An object of class \code{LAS}}

\item{res}{numeric. The size of a grid cell in LiDAR data coordinates units. Default is 4 = 16 square meters.}
}
\value{
It returns a \code{data.table} of the class \code{lasmetrics} which enables easier plotting and
RasterLayer casting.
}
\description{
Creates a pulse density map using a LiDAR cloud of points. This function is an alias
for \code{grid_metrics(obj, f, res} with \code{f} = \code{length(unique(pulseID))/res^2)}
}
\examples{
LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
lidar = readLAS(LASfile)

lidar \%>\% grid_density(5) \%>\% plot
lidar \%>\% grid_density(10) \%>\% plot
}
\seealso{
\link[lidR:grid_metrics]{grid_metrics}

Other grid_alias: \code{\link{grid_canopy}}
}

