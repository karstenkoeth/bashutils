#!/bin/bash

# #########################################
#
# Overview
#
# On the RKI Dashboard, the mapping between regions and the regien number is shown: In the map,
# select a region. On the appearing popup, the region number is mentioned.
#
# Links
#
# https://experience.arcgis.com/experience/478220a4c454480e823b17327b2bf1d4 - RKI Dashboard

# #########################################
#
# Uses:
#
# cut
# curl
# echo
# grep
# jq
# sed

# #########################################
#
# Versions
#
# 2021-04-09 0.01 kdk First Version
# 2021-04-11 0.02 kdk Automatic print out the "Bezirk"
# 2021-04-22 0.03 kdk With Links

PROG_NAME="rki"
PROG_VERSION="0.03"
PROG_DATE="2021-04-22"
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

# Region Numbers:
#BEREICH="60"
#BEREICH="27" # Hannover
BEREICH="193" # Stadtkreis Karlsruhe
#BEREICH="194" # Landkreis Karlsruhe
#BEREICH="121" # Landkreis Bergstraße
#BEREICH="199" # Landkreis Rhein-Neckar-Kreis

# #########################################
#
# Functions
#

# #########################################
# deleteQuotationMark()
# Parameter
#    1: String to remove the quotation marks from
# Return
#    1: Input string without quotation marks
# All quotation marks will be removed.
function deleteQuotationMark()
{
    s=$(echo "$1" | sed -- "s/\"//g")
    echo "$s"
}

# #########################################
#
# Main
#

STR=$(curl --no-progress-meter "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=OBJECTID=$BEREICH&outFields=cases,deaths,cases_per_100k,cases7_per_100k,GEN,BEZ&outSR=4326&f=json")

RKI=$(echo "$STR" | jq ".features" | grep "cases7_per_100k" | cut -d ":" -f 2 - | cut -d "," -f 1 - )
GEN=$(echo "$STR" | jq ".features" | grep "GEN" | cut -d ":" -f 2 - | cut -d "," -f 1 - )

echo "$(deleteQuotationMark "$GEN"): $RKI"
