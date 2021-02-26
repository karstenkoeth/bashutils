#!/bin/bash

# #########################################
#
# Overview
#
# This script subscribes to a mqtt broker and write messages to a file.

# #########################################
#
# Versions
#
# 2021-02-26 0.01 kdk First Version derived from bashutils/bash-script-template.sh


PROG_NAME="mqtt2file"
PROG_VERSION="0.01"
PROG_DATE="2021-02-26"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="mqtt2file.sh"

# #########################################
#
# TODOs
#

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
# Includes
#
# TODO: Given in this way, the include file must be in same directory the 
#       script is called from. We have to auto-detect the path to the binary.
# source bashutils_common_functions.bash



# #########################################
#
# Constants
#


# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

# #########################################
#
# Functions
#


# #########################################
# showHelp()
# Parameter
#    -
# Return Value
#    -
# Show help.
function showHelp()
{
    echo "[$PROG_NAME:STATUS] Program Parameter:"
    echo "    -V     : Show Program Version"
    echo "    -h     : Show this help"
    echo "Copyright $PROG_DATE by Karsten Köth"
}

# #########################################
# showVersion()
# Parameter
#    -
# Return Value
#    -
# Show version information.
function showVersion()
{
    echo "$PROG_NAME ($PROG_CLASS) $PROG_VERSION"
}

# #########################################
#
# Main
#

echo "[$PROG_NAME:STATUS] Starting ..."

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ -f "$1" ] ; then
        echo "[$PROG_NAME:STATUS] Input file exists."
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:ERROR] No input file. Exit." ; exit;
    fi
else
    echo "[$PROG_NAME:ERROR] Program needs one input file as parameter. Exit."; exit;
fi

# Main loop:

endOfLoop=0

while [ $endOfLoop -lt 1 ]
do
    # Read incoming MQTT message:
    # To get this, this program is started with "mqtt2rest.sh" or "mosquitto_sub -h localhost -t prototype | mqtt2file.sh"
    read -r variable 
    # Remove newline, ...:
    variable=${variable%%$'\r'}
    # Debug Output:
    echo "[$PROG_NAME:DEBUG] '$variable'"
    # Write to file:
    TmpDir="$HOME/tmp/mqtt"
    TmpUuid="1234"
    # The file must be in same tree as created with "http-text.sh"
    # Only store non empty messages:
    if [ -n "$variable" ] ; then
        echo "$variable" > "$TmpDir/$TmpUuid/value.txt"
    else
        echo "[$PROG_NAME:DEBUG] Skip empty message ..."
    fi
done


echo "[$PROG_NAME] Done."
