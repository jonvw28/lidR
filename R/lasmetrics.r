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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# ===============================================================================

#' Predefined standard metrics function
#'
#' Predefined function usable in \link[lidR:grid_metrics]{grid_metrics} and \link[lidR:cloud_metrics]{cloud_metrics}
#' and their convenient shortcuts. The philosophy of \code{lidR} package is to provide an easy way
#' to compute your own new metrics not to provide them. However a set of classical metric is
#' already predefined to save time, save pain and to ensure computation efficiency. To use
#' these function please read Details and examples sections.
#'
#' The function names, their parameters and the output names  of the metrics rely on a nomenclature chose to get short
#' names and labels:
#' \itemize{
#' \item{\code{z}: refer to the elevation}
#' \item{\code{i}: refer to the intensity}
#' \item{\code{rn}: refer to the return number}
#' \item{\code{q}: refer to quantile}
#' \item{\code{a}: refer to the ScanAngle}
#' \item{\code{n}: refer to a number (a count)}
#' }
#' For example the metric named \code{zq60} refer to the elavation, quantile, 60.
#' It's the 60th percentile of elevations. The metric \code{nground} refer to a count. It's the
#' number of point classified as ground. The function \code{stdmetric_i} refer to metrics of
#' intensity. If a doubt subsist you can retrive a description of each existing metric
#' on the lidR wiki page: https://github.com/Jean-Romain/lidR/wiki/stdmetrics.\cr\cr
#' Some functions have optional parameters. If these parameter are not provided the function
#' computes only a subset of existing metrics. For example \code{stdmetrics_i} requieres the intensity
#' values, but if the elevation values are provided it can computed more metrics such as cumulative
#' intensity at a given percentile of height.\cr\cr
#' Each function have a convenient variable associated. It is the name of the function with a
#' dot before the name. It enables to use the function without writing parametrers. The cost
#' of such feature is a non flexibility. It corresponds to a predefined behaviour (see examples)
#'
#' @param x,y,z,i,a Coordinates of the points, Intensity and ScanAngle
#' @param rn,class ReturnNumber, Classification
#' @param pulseID The number referencing each pulse
#' @param dz Layer thickness for metric requiering such data such as \link[lidR:entropy]{entropy}
#' @examples
#' LASfile <- system.file("extdata", "Megaplot.laz", package="lidR")
#' lidar = readLAS(LASfile, all = TRUE)
#'
#' # All the predefined function
#' lidar %>% grid_metrics(stdmetrics(X,Y,Z,Intensity, ScanAngle,
#'                                   ReturnNumber, Classification, pulseID,
#'                                   dz = 1))
#'
#' # Super convenient shortcut
#' lidar %>% grid_metrics(.stdmetrics)
#'
#' # Basic metrics from intensities
#' lidar %>% grid_metrics(stdmetrics_i(Intensity))
#'
#' # All the metrics from intensities
#' lidar %>% grid_metrics(stdmetrics_i(Intensity, Z, Classification, ReturnNumber))
#'
#' # Super convinient shortcut
#' lidar %>% grid_metrics(.stdmetrics_i)
#'
#' # Compute the metrics only on first return
#' lidar %>% lasfilterfirst %>% grid_metrics(.stdmetrics_z)
#'
#' # Compute the metrics with a threshold at 2 meters
#' lidar %>% lasfilter(Z > 2) %>% grid_metrics(.stdmetrics_z)
#'
#' # Works also with cloud_metrics
#' lidar %>% cloud_metrics(.stdmetrics)
#'
#' # Combine some predefined function with your own new metrics
#' # Here convenient shortcut are no more usable.
#' myMetrics = function(z, i)
#' {
#'   metrics = list(
#'     mymetric1 = mean(z*i),       # Mean of products of z by intensity
#'     mymetric2 = mean(z[i > 20])  # Mean elevation of point with an intensity > 20
#'   )
#'
#'   return( c(metrics, stdmetrics_z(z)) )
#' }
#'
#' lidar %>% grid_metrics(myMetrics(Z, Intensity))
#'
#' # You can write your own convenient shorcut like that
#' .myMetrics = expression(myMetrics(Z,Intensity))
#'
#' lidar %>% grid_metrics(.myMetrics)
#' @seealso
#' \link[lidR:grid_metrics]{grid_metrics}
#' \link[lidR:cloud_metrics]{cloud_metrics}
#' @rdname stdmetrics
#' @export
stdmetrics = function(x, y, z, i, a, rn, class, pulseID, dz = 1)
{
  C  = stdmetrics_ctrl(x, y, z, a)
  Z  = stdmetrics_z(z, dz)
  I  = stdmetrics_i(i, class, rn)
  RN = stdmetrics_rn(rn, class)
  PU = stdmetrics_pulse(pulseID, rn)

  metrics = c(C, Z, I, RN, PU)
  return(metrics)
}

#' @rdname stdmetrics
#' @export
.stdmetrics = expression(stdmetrics(X,Y,Z,Intensity, ScanAngle, ReturnNumber, Classification, pulseID, dz = 1))

#' Gap fraction profile
#'
#' Computes the gap fraction profile using the method of Bouvier et al. (see reference)
#'
#' The function assesses the number of laser points that actually reached the layer
#' z+dz and those that passed through the layer [z, z+dz]. By definition the layer 0
#' will always return 0 because no returns pass through the ground. Therefore, the layer 0 is removed
#' from the returned results.
#'
#' @param z vector of positive z coordinates
#' @param dz numeric. The thickness of the layers used (height bin)
#' @return A data.frame containing the bin elevations (z) and the gap fraction for each bin (gf)
#' @examples
#' z = c(rnorm(1e4, 25, 6), rgamma(1e3, 1, 8)*6, rgamma(5e2, 5,5)*10)
#' z = z[z<45 & z>0]
#'
#' hist(z, n=50)
#'
#' gapFraction = gap_fraction_profile(z)
#'
#' plot(gapFraction, type="l", xlab="Elevation", ylab="Gap fraction")
#' @references Bouvier, M., Durrieu, S., Fournier, R. a, & Renaud, J. (2015).  Generalizing predictive models of forest inventory attributes using an area-based approach with airborne LiDAR data. Remote Sensing of Environment, 156, 322-334. http://doi.org/10.1016/j.rse.2014.10.004
#' @seealso \link[lidR:LAD]{LAD}
#' @export gap_fraction_profile
gap_fraction_profile = function (z, dz = 1)
{
  maxz = max(z)

  bk = seq(0, ceiling(maxz), dz)

  histogram = graphics::hist(z, breaks = bk, plot = F)
  h = histogram$mids
  p = histogram$counts/sum(histogram$count)

  p = c(p, 0)

  cs = cumsum(p)
  i = data.table::shift(cs) /cs
  i[is.na(i)] = 0

  i[is.nan(i)] = NA

  z = h[-1]
  i = i[-c(1, length(i))]

  return(data.frame(z, gf = i))
}

#' Leaf area density
#'
#' Computes a leaf area density profile based on the method of Bouvier et al. (see reference)
#'
#' The function assesses the number of laser points that actually reached the layer
#' z+dz and those that passed through the layer [z, z+dz] (see \link[lidR:gap_fraction_profile]{gap_fraction_profile}).
#' Then it computes the log of this quantity and divides it by the extinction coefficient k as described in Bouvier
#' et al. By definition the layer 0 will always return infinity because no returns pass through
#' the ground. Therefore, the layer 0 is removed from the returned results.
#'
#' @param z vector of positive z coordinates
#' @param dz numeric. The thickness of the layers used (height bin)
#' @param k numeric. is the extinction coefficient
#' @return A data.frame containing the bin elevations (z) and leaf area density for each bin (lad)
#' @examples
#' z = c(rnorm(1e4, 25, 6), rgamma(1e3, 1, 8)*6, rgamma(5e2, 5,5)*10)
#' z = z[z<45 & z>0]
#'
#' lad = LAD(z)
#'
#' plot(lad, type="l", xlab="Elevation", ylab="Leaf area density")
#' @references Bouvier, M., Durrieu, S., Fournier, R. a, & Renaud, J. (2015).  Generalizing predictive models of forest inventory attributes using an area-based approach with airborne LiDAR data. Remote Sensing of Environment, 156, 322-334. http://doi.org/10.1016/j.rse.2014.10.004
#' @seealso \link[lidR:gap_fraction_profile]{gap_fraction_profile}
#' @export LAD
LAD = function(z, dz = 1, k = 0.5) # (Bouvier et al. 2015)
{
	ld = gap_fraction_profile(z, dz)

	if(anyNA(ld))
	  return(NA_real_)

	lad = ld$gf
	lad = -log(lad)/k

	lad[is.infinite(lad)] = NA

	lad = lad

	return(data.frame(z = ld$z, lad))
}

#' Normalized Shannon diversity index
#'
#' A normalized Shannon vertical complexity index
#'
#' The Shannon diversity index is a measure for quantifying diversity and is
#' based on the number and frequency of species present. This index, developed by
#' Shannon and Weaver for use in information theory, was successfully transferred
#' to the description of species diversity in biological systems (Shannon 1948).
#' Here it is applied to quantify the diversity and the evenness of an elevational distribution
#' of LiDAR points. It makes bins between 0 and the maximum elevation.
#'
#' @param z vector of positive z coordinates
#' @param by numeric. The thickeness of the layers used (height bin)
#' @param zmax numeric. Used to turn the function entropy to the function \link[lidR:VCI]{VCI}.
#' @seealso
#' \link[lidR:VCI]{VCI}
#' @examples
#' z = runif(10000, 0, 10)
#'
#' # expected to be close to 1. The highest diversity is given for a uniform distribution
#' entropy(z, by = 1)
#'
#'  z = runif(10000, 9, 10)
#'
#' # Must be 0. The lowest diversity is given for a unique possibility
#' entropy(z, by = 1)
#'
#' z = abs(rnorm(10000, 10, 1))
#'
#' # expected to be between 0 and 1.
#' entropy(z, by = 1)
#' @references
#' Pretzsch, H. (2008). Description and Analysis of Stand Structures. Springer Berlin Heidelberg. http://doi.org/10.1007/978-3-540-88307-4 (pages 279-280)
#' Shannon, Claude E. (1948), "A mathematical theory of communication," Bell System Tech. Journal 27, 379-423, 623-656.
#' @return A number between 0 and 1
#' @export entropy
entropy = function(z, by = 1, zmax = NULL)
{
  # Fixed entropy (van Ewijk et al. (2011)) or flexible entropy
  if(is.null(zmax))
	  zmax = max(z)

	# If zmax < 3 it is meaningless to compute entropy
	if(zmax < 2)
		return(NA_real_)

  if(min(z) < 0)
    stop("Entropy found negatives values. Returned NA.")

	# Define the x meters bins from 0 to zmax (rounded to the next integer)
	bk = seq(0, ceiling(zmax), by)

	# Compute the p for each bin
	hist = hist(z, breaks = bk, plot=F)$count
	hist = hist/sum(hist)

	# Remove bin where there are no points because of log(0)
	p    = hist[hist > 0]
	pref = rep(1/length(hist), length(hist))

	# normalized entropy
	S = - sum(p*log(p)) / -sum(pref*log(pref))

	return(S)
}

#' Vertical Complexity Index
#'
#' A fixed normalization of the entropy function (see references)
#' @param z vector of z coordinates
#' @param by numeric. The thickness of the layers used (height bin)
#' @param zmax numeric. Used to turn the function entropy to the function vci.
#' @return A number between 0 and 1
#' @seealso
#' \link[lidR:entropy]{entropy}
#' @examples
#' z = runif(10000, 0, 10)
#'

#' VCI(z, by = 1, zmax = 20)
#'
#' z = abs(rnorm(10000, 10, 1))
#'
#' # expected to be closer to 0.
#' VCI(z, by = 1, zmax = 20)
#' @references van Ewijk, K. Y., Treitz, P. M., & Scott, N. A. (2011). Characterizing Forest Succession in Central Ontario using LAS-derived Indices. Photogrammetric Engineering and Remote Sensing, 77(3), 261-269. Retrieved from <Go to ISI>://WOS:000288052100009
#' @export VCI
VCI = function(z, zmax, by = 1)
{
  z = z[z < zmax]

  return(entropy(z, by, zmax))
}

#' fractal_dimension
#'
#' Computes the fractal dimension of a surface. The fractal dimension is a measure
#' of roughness.
#'
#' Fractal dimension computes the roughness based on the box counting method (see Taud and Parrot).
#' If the input has an NA value, it returns NA. If the input is too small it returns NA.
#' If the input matrix is not a square matrix, the function cuts the input matrix to create a square matrix.
#' @param mtx numeric matrix that is the representation of a surface model
#' @return numeric. A number between 0 and 3. 3 being the dimension of a volume
#' @references Taud, H., & Parrot, J.-F. (2005). Mesure de la rugosite des MNT a l'aide de la dimension fractale. Geomorphologie : Relief, Processus, Environnement, 4, 327-338. http://doi.org/10.4000/geomorphologie.622
#' @examples
#' mtx = matrix(runif(100), 10, 10)
#' fractal_dimension(mtx)
#' @export fractal_dimension
fractal_dimension = function(mtx)
{
  if( sum(is.na(mtx)) > 0 )
    return(NA_real_)

  size = min(dim(mtx))

  if( size < 6)
    return(NA_real_)

  size = ifelse(size %% 2 == 0, size, size-1)

  mtx = mtx[1:size, 1:size]

  q = 1:size
  q = q[size %% q == 0]

  if(length(q) < 3)
    return(as.numeric(NA))

  nbbox = sapply(q, .countBox, mtx=mtx)

  lm = stats::lm(log(nbbox) ~ log(q))

  return(abs(as.numeric(stats::coefficients(lm)[2])))
}

.countBox = function(q, mtx)
{
	  rg <- (row(mtx)-1)%/%q+1
    cg <- (col(mtx)-1)%/%q+1
    rci <- (rg-1)*max(cg) + cg
    N <- prod(dim(mtx))/(q^2)

	  lasclip = lapply(1:N, function(x) mtx[rci==x])
	  box = sapply(lasclip,max)/q

	  return(sum(box))
}

#' @rdname stdmetrics
#' @export
stdmetrics_z = function(z, dz = 1)
{
  zmax <- zmean <- zsd <- zcv <- zskew <- zkurt <- zentropy <- NULL
  n = length(z)

  probs = seq(0.05, 0.95, 0.05)
  zq 	  = as.list(stats::quantile(z, probs))
  names(zq) = paste("zq", probs*100, sep="")

  metrics = list(
    zmax = max(z),
    zmean = mean(z),
    zsd   = stats::sd(z),
    zskew = (sum((z - zmean)^3)/n)/(sum((z - zmean)^2)/n)^(3/2),
    zkurt = n * sum((z - zmean)^4)/(sum((z - zmean)^2)^2),
    zentropy  = entropy(z, dz)
  )
  metrics = c(metrics, zq)

  return(metrics)
}

#' @rdname stdmetrics
#' @export
.stdmetrics_z = expression(stdmetrics_z(Z, dz =1))

#' @rdname stdmetrics
#' @export
stdmetrics_i = function(i, z = NULL, class = NULL, rn = NULL)
{
  itot <- imax <- imean <- isd <- icv <- iskew <- ikurt <- NULL
  icumzq10 <- icumzq30 <- icumzq50 <- icumzq70 <- icumzq90 <- NULL
  itot1st <- itot2sd <- itot3rd <- itot4th  <- itot5th <- NULL
  n = length(i)

  probs = seq(0.05, 0.95, 0.05)
  iq 	  = as.list(stats::quantile(i, probs))
  names(iq) = paste("iq", probs*100, sep="")

  metrics = list(
    itot = sum(i),
    imax  = max(i),
    imean = mean(i),
    isd   = stats::sd(i),
    iskew = (sum((i - imean)^3)/n)/(sum((i - imean)^2)/n)^(3/2),
    ikurt = n * sum((i - imean)^4)/(sum((i - imean)^2)^2)
  )

  if(!is.null(class))
  {
    metrics = c(metrics, list(itotground = sum(i[class == 2])))
  }

  if(!is.null(z))
  {
    zq = stats::quantile(z, probs = seq(0.1, 0.9, 0.2))

    icum = list(
      icumzq10 = sum(i[z <= zq[1]]),
      icumzq30 = sum(i[z <= zq[2]]),
      icumzq50 = sum(i[z <= zq[3]]),
      icumzq70 = sum(i[z <= zq[3]]),
      icumzq90 = sum(i[z <= zq[5]])
    )

    metrics = c(metrics, icum)
  }

  if(!is.null(rn))
  {
    itox = list(
      itot1st = sum(i[rn == 1]),
      itot2nd = sum(i[rn == 2]),
      itot3rd = sum(i[rn == 3]),
      itot4th = sum(i[rn == 4]),
      itot5th = sum(i[rn == 5])
    )

    metrics = c(metrics, itox)
  }

  return(metrics)
}

#' @rdname stdmetrics
#' @export
.stdmetrics_i = expression(stdmetrics_i(Intensity, Z, Classification, ReturnNumber))

#' @rdname stdmetrics
#' @export
stdmetrics_rn = function(rn, class = NULL)
{
  nground <- NULL

  n = length(rn)
  nrn = table(factor(rn, levels=c(1:9)))
  nrn = as.list(nrn)
  names(nrn) = paste0("n", names(nrn), "th")

  metrics = nrn

  if(!is.null(class))
  {
    metrics = c(metrics, list(nground = sum(class == 2)))
  }

  return(metrics)
}

#' @rdname stdmetrics
#' @export
.stdmetrics_rn = expression(stdmetrics_rn(ReturnNumber, Classification))


#' @rdname stdmetrics
#' @export
stdmetrics_pulse = function(pulseID, rn)
{
  . <- nr <- NULL

  dt = data.table::data.table(pulseID, rn)

  np_with_x_return = dt[, .(nr = max(rn)), by = pulseID][, .N, by = nr]
  data.table::setorder(np_with_x_return, nr)

  np = numeric(9)
  names(np) = paste0("npulse", 1:9, "return")
  np[np_with_x_return$nr] = np_with_x_return$N
  np = as.list(np)

  return(np)
}

#' @rdname stdmetrics
#' @export
.stdmetrics_pulse = expression(stdmetrics_pulse(pulseID, ReturnNumber))

#' @rdname stdmetrics
#' @export
stdmetrics_ctrl = function(x, y, z, a)
{
  xmax = max(x)
  ymax = max(y)
  xmin = min(x)
  ymin = min(y)
  n    = length(z)
  angle = abs(a)
  area = (xmax - xmin)*(ymax - ymin)

  metrics = list(
    n    = n,
    area = area,
    angle = mean(angle)
  )

  return(metrics)
}

#' @rdname stdmetrics
#' @export
.stdmetrics_ctrl = expression(stdmetrics_ctrl(X, Y, Z, ScanAngle))


# canopy = canopyMatrix(x,y,z, canopyResolution)

# canopyq    = as.numeric(quantile(canopy, seq(0.1, 0.9, 0.2), na.rm=T))
#
# canopymean = mean(canopy, na.rm=T)
# canopysd   = sd(canopy, na.rm=T)
# canopycv   = canopysd/canopymean
#
# canopyq10  = canopyq[1]
# canopyq30  = canopyq[2]
# canopyq50  = canopyq[3]
# canopyq70  = canopyq[4]
# canopyq90  = canopyq[5]
#
# canopyfd   = fractal.dimension(canopy)
#
# perc.canopy.na = sum(is.na(canopy))/length(canopy) * 100
#
# CC2  = sum(canopy > 2, na.rm=T)/length(canopy)*100
# CC10 = sum(canopy > 10, na.rm=T)/length(canopy)*100
# CC20 = sum(canopy > 20, na.rm=T)/length(canopy)*100
# CC30 = sum(canopy > 30, na.rm=T)/length(canopy)*100
# CC40 = sum(canopy > 40, na.rm=T)/length(canopy)*100
