% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grid_metrics.r
\docType{methods}
\name{grid_metrics}
\alias{grid_metrics}
\alias{grid_metrics,LAS-method}
\title{Rasterize the space and compute metrics for each cell}
\usage{
grid_metrics(obj, res, func, start = c(0, 0), option = NULL)

\S4method{grid_metrics}{LAS}(obj, res, func, start = c(0, 0), option = NULL)
}
\arguments{
\item{obj}{An object of class \code{LAS}}

\item{res}{numeric. The size of the cells}

\item{func}{the function to be apply to each cells}

\item{start}{vector x and y coordinates for the reference raster. Default is (0,0).}

\item{option}{character. Could be \code{"split_flightline"}. In this case the algorithm will compute the metrics for each flightline individually. It returns the same cells several times in overlap.}
}
\value{
It returns a \code{data.table} containing the metrics for each cell. The table has the class "grid_metrics" enabling easy plotting.
}
\description{
Computes a series of descriptive statistics for a LiDAR dataset for each cell
of a grid.
}
\details{
Computes a series of descriptive statistics defined by the user. Output is a
data.frame in which each line is a raster (single grid cell), each column is a metric.
grid_metrics is similar to cloud_metrics except it computes metrics within each cell
in the output grid. The grid cell coordinates are pre-determined for a given resolution.
So the algorithm will always provide the same coordinates independently of the dataset.
When start = (0,0) and res = 20 grid_metrics will produce the following raster centers: (10,10), (10,30), (30,10) etc..
When start = (-10, -10) and res = 20 grid_metrics will produce the following raster centers: (0,0), (0,20), (20,0) etc..
In Quebec (Canada) reference is (-831600,  117980) in the NAD83 coordinate system. The function to be applied to each cell is a classical function (see examples) that returns a labelled list of metrics.
The following existing function can help the user to compute some metrics:

\itemize{
\item{\link[lidR:entropy]{entropy}}
\item{\link[lidR:VCI]{VCI}}
\item{\link[lidR:local_maximum]{local_maximum}}
\item{\link[lidR:LAD]{LAD}}
\item{\link[lidR:canopy_closure]{canopy_closure}}
\item{\link[lidR:fractal_dimension]{fractal_dimension}}
} Basically there are no predifined metrics. Users must write their own functions to create metrics.
grid_metrics will dispach the LiDAR data for each cell in the user's function. The user writes their
function without considering grid cells, only a cloud of points (see example).
}
\examples{
LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
lidar = readLAS(LASfile)

# Canopy surface model with 4 m^2 cells
grid_metrics(lidar, 2, max(Z)) \%>\% plot

# Mean height with 400 m^2 cells
grid_metrics(lidar, 20, mean(Z)) \%>\% plot

# Define your own metric function
myMetrics = function(z, i, angle, pulseID)
{
  ret = list(
        npulse  = length(unique(pulseID)),
        hmean   = mean(z),
        hmax    = max(z),
        imean   = mean(i),
        angle   = mean(abs(angle))
        )

   return(ret)
 }

metrics = grid_metrics(lidar, 20, myMetrics(Z, Intensity, ScanAngle, pulseID))

plot(metrics, "hmean")
plot(metrics, "hmax")
plot(metrics, "imean")
#etc.
}
