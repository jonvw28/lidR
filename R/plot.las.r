# ===============================================================================
#
# PROGRAMMERS:
#
# jean-romain.roussel.1@ulaval.ca  -  https://github.com/Jean-Romain/lidR
#
# COPYRIGHT:
#
# Copyright 2016 Jean-Romain Roussel
#
# This file is part of lidR R package.
#
# lidR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# ===============================================================================



#' Plot LiDAR data
#'
#' This functions implements a 3D plot method for LAS objects
#'
#' @aliases plot plot.LAS
#' @param x An object of the class \code{LAS}
#' @param y Unused (inherited from R base)
#' @param color characters. The field used to color the points. Default is Z coordinates. Or a vector of colors.
#' @param colorPalette characters. A color palette name. Default is \code{height.colors} provided by the package lidR
#' @param bg The color for the background. Default is black.
#' @param trim numeric. Enables trimming of values when outliers break the color palette range.
#' Default is 1, meaning that the whole range of values is used for the color palette.
#' 0.9 means that 10\% of the highest values are not used to define the color palette.
#' In this case values higher than the 90th percentile are set to the highest color. They are not removed.
#' @param \dots Supplementary parameters for \link[rgl:points3d]{points3d}
#' @examples
#' LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
#' lidar = readLAS(LASfile)
#'
#' plot(lidar)
#'
#' # Outliers of intensity breaks the color range. Use the trim parameter.
#' plot(lidar, color = "Intensity", colorPalette = heat.colors)
#' plot(lidar, color = "Intensity", colorPalette = heat.colors, trim = 0.99)
#' @seealso
#' \link[rgl:points3d]{points3d}
#' \link[lidR:height.colors]{height.colors}
#' \link[lidR:forest.colors]{forest.colors}
#' \link[grDevices:heat.colors]{heat.colors}
#' \link[grDevices:colorRamp]{colorRampPalette}
#' \link[lidR:LAS]{Class LAS}
#' @export
plot.LAS = function(x, y, color = "Z", colorPalette = height.colors, bg = "black",  trim = 1, ...)
{
  inargs <- list(...)

  inargs$col = color

  if(length(color) == 1)
  {
    if(color %in% names(x@data))
    {
      data = unlist(x@data[,color, with = FALSE])

      if(is.numeric(data))
        inargs$col = set.colors(data, colorPalette, 50, trim)
      else if(is.character(data))
        inargs$col = data
      else if(is.logical(data))
        inargs$col = set.colors(as.numeric(data), colorPalette, 2)

      inargs$col[is.na(inargs$col)] = "lightgray"
    }
  }

  rgl::open3d()
  rgl::rgl.bg(color = bg)
  do.call(rgl::points3d, c(list(x=x@data$X, y=x@data$Y, z=x@data$Z), inargs))
}
