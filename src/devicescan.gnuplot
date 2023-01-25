# #########################################
#
# Overview
#
# This script prints the time series uptime data of devicescan with gnuplot.
# 

# #########################################
#
# Versions
#
# 2020-07-28 0.01 kdk First Version. The assethubUsageAssets is a copy of this script with some comments in.
# 2020-07-29 0.02 kdk With program parameter
# 2021-01-22 0.03 kdk With 2021 range
# 2021-01-25 0.04 kdk With Y-Range starting at 0
# 2022-01-18 0.05 kdk For Year 2022
# 2023-01-17 0.06 kdk For Year 2023
# 2023-01-25 0.07 kdk Copied from assethub-usage/src/AssetHubUsage.gnuplot to bashutils/src/devicescan.gnuplot

# #########################################
#
# TODOs
#

# #########################################
#
# MIT license (MIT)
#
# Copyright 2023 - 2020 Karsten Köth
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# #########################################
#
# Main
#

# Program Parameter:
#  "FILENAME"
#  "TITLE"

# Set data format:
set xdata time
set timefmt "%Y-%m-%d"
set datafile separator ","

# Set layout format:
#set terminal png font "Arial"
# Not at Windows:
#set terminal png font "Helvetica"
set style function filledcurves x1
set terminal png size 1920,1080
set xlabel 'Date'
set key off # Do not show legend
set xrange ["2023-01-01" : "2023-12-31"]
set format x "%Y-%m-%d"
set yrange [0:*]
set border 15 front lw 2
set grid

set title TITLE
plot FILENAME using 1:3 with lines lw 2
