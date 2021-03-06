![CRAN](https://img.shields.io/badge/CRAN-1.0.2-brightgreen.svg)  ![Github](https://img.shields.io/badge/Github-1.0.2-green.svg) ![Devel](https://img.shields.io/badge/devel-1.1.0.dev-yellowgreen.svg) ![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)

R package for Airborne LiDAR Data Manipulation and Visualization for Forestry Applications

The lidR package provides functions to read and write `.las` and `.laz` files, plot a point cloud, compute metrics using an area-based approach, compute digital canopy models, thin lidar data, manage a catalog of datasets, automatically extract ground inventories, process a set of tiles in multicore, classify data from shapefiles, and provides other tools to manipulate LiDAR data. The lidR package is designed mainly for research purposes using an area-based approach.

lidR provides an open-source and R-based implementation of several classical functions used in software dedicated to LiDAR data manipulation. lidR is flexible because it allows the user to program their own tools and manipulate their own objects in R rather than rely on a set of predefined tools.

Please contact the author for bug reports or feature requests (on github, preferably). I enjoy implementing new features!

1. [Features](#features)
2. [Install lidR from github](#install-lidr-from-github)
3. [Some examples](#some-examples)
4. [Changelog](#changelog)

# Features (not exhaustive)

- [Read write .las and .laz files](https://github.com/Jean-Romain/lidR/wiki/readLAS)
- [Plot 3D LiDAR data](https://github.com/Jean-Romain/lidR/wiki/lasplot)
- [Retrieve indiviual pulses and flightlines](https://github.com/Jean-Romain/lidR/wiki/readLAS#dynamically-computed-fields)
- [Compute any set of metrics using an area based approach](https://github.com/Jean-Romain/lidR/wiki/grid_metrics)
- [Compute any set of metrics on a cloud of points](https://github.com/Jean-Romain/lidR/wiki/cloud_metrics)
- [Classify and clip data from geographic shapefiles](https://github.com/Jean-Romain/lidR/wiki/lasclassify)
- [Colorize a point cloud from RGB images](https://github.com/Jean-Romain/lidR/wiki/lasclassify)
- [Filter a cloud of points based on any condition test](https://github.com/Jean-Romain/lidR/wiki/lasfilter)
- [Clip data based on discs, rectangles or polygons](https://github.com/Jean-Romain/lidR/wiki/lasclip)
- [Manage a catalog of `.las` tiles](https://github.com/Jean-Romain/lidR/wiki/catalog)
- [Thin a point cloud to reach a homogeneous pulse density](https://github.com/Jean-Romain/lidR/wiki/lasdecimate)
- [Automatically extract a set of ground plot inventories](https://github.com/Jean-Romain/lidR/wiki/catalog_queries)
- [Analyse a full set of tiles in parallel computing](https://github.com/Jean-Romain/lidR/wiki/catalog_#process-all-the-file-of-a-catalog_apply)
- [Compute a digital canopy model (DCM)](https://github.com/Jean-Romain/lidR/wiki/grid_canopy)
- [Compute a digital terrain model (DTM)](https://github.com/Jean-Romain/lidR/wiki/grid_terrain)
- [Normalize a point cloud substracting a DTM](https://github.com/Jean-Romain/lidR/wiki/lasnormalize)

# Install lidR from github

To install the package from github make sure you have a working development environment.

* **Windows**: Install [Rtools.exe](https://cran.r-project.org/bin/windows/Rtools/).  
* **Mac**: Install `Xcode` from the Mac App Store.
* **Linux**: Install the R development package, usually called `r-devel` or `r-base-dev`

Install devtools: `install.packages("devtools")`, then:

````r
devtools::install_github("Jean-Romain/rlas", dependencies=TRUE)
devtools::install_github("Jean-Romain/lidR", dependencies=TRUE)
````
    
# Some examples

<table>
  <tr>
    <th>Plot data</th>
    <th>Compute a simple metric</th>
  </tr>
  <tr>
    <td valign="top">
<pre>lidar = readLAS("myfile.las")
plot(lidar)</pre>
<img src="https://raw.githubusercontent.com/Jean-Romain/lidR/gh-pages/images/plot3d_1.jpg" alt="" style="max-width:100%;">
    </td>
    <td valign="top">
<pre>metric = grid_metrics(lidar, mean(Z))
plot(metric)</pre>
<img src="https://raw.githubusercontent.com/Jean-Romain/lidR/gh-pages/images/gridMetrics-mean.jpg" alt="" style="max-width:100%;">
    </td>
  </tr>
    <tr>
    <th>Manage a catalog</th>
    <th>Deal with DTM</th>
  </tr>
  <tr>
    <td valign="top">
<pre>ctg = catalog("folder of .las files")
plot(ctg)</pre>
<img src="https://raw.githubusercontent.com/Jean-Romain/lidR/gh-pages/images/catalog.png" alt="" style="max-width:100%;">
    </td>
    <td valign="top">
<pre>dtm = grid_terrain(lidar)
plot3d(dtm)</pre>
<img src="https://raw.githubusercontent.com/Jean-Romain/lidR/gh-pages/images/dtm.jpg" alt="" style="max-width:100%;">
    </td>
  </tr>
</table>

# Changelog

### v1.0.1

* Change: split the package in two parts. 'lidR' rely on 'rlas' to read binary files.
