#!/bin/bash

# #########################################
#
# Overview
#
# This template can be used for bash scripts.
# See also the library with a lot of useful functions in: bashutils_common_functions.bash

# #########################################
#
# Versions
#
# 2021-04-09 0.01 kdk First Version

PROG_NAME="rki"
PROG_VERSION="0.01"
PROG_DATE="2021-04-08"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="rki.sh"

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2021 Karsten Köth
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
# Variables
#

#BEREICH="60"
#BEREICH="27" # Hannover
BEREICH="193" # Stadtkreis Karlsruhe
#BEREICH="194" # Landkreis Karlsruhe
#BEREICH="121" # Landkreis Bergstraße
#BEREICH="199" # Landkreis Rhein-Neckar-Kreis

STR=$(curl --no-progress-meter "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=$BEREICH&outFields=cases,deaths,cases_per_100k,cases7_per_100k,GEN,BEZ&outSR=4326&f=json")

RKI=$(echo "$STR" | jq ".features" | grep "cases7" | cut -d ":" -f 2 - | cut -d "," -f 1 - )

echo "Stadt Karlsruhe: $RKI"
