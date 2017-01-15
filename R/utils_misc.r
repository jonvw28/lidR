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

round_any <- function(x, accuracy, f = round)
{
  f(x / accuracy) * accuracy
}

make_grid = function(xmin, xmax, ymin, ymax, res)
{
  xo = seq(round_any(xmin, res), round_any(xmax, res), res) %>% round(2)
  yo = seq(round_any(ymin, res), round_any(ymax, res), res) %>% round(2)

  grid = expand.grid(X = xo, Y = yo)
  data.table::setDT(grid)

  return(grid)
}