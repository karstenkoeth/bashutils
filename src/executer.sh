#!/bin/bash

# #########################################
#
# Overview
#
# This bash script permanently looks for commands inside a special directory and executes these.

# #########################################
#
# Versions
#
# 2021-01-29 0.01 kdk First Version

PROG_NAME="Executer"
PROG_VERSION="0.01"
PROG_DATE="2021-01-29"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="executer.sh"
PROG_LIBRARYNAME="bashutils_common_functions.bash"

# #########################################
#
# TODOs
#
# Write it and test it.

# #########################################
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

TRUSTED_DIR="~/executer"

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

# Standard Folders and Files

MainFolder="_"
RunFolder="_"

RunFile="_"
LogFile="_"

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
    if [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:WARNING] Unknown program parameter." ;
    fi
fi

# Start main loop

echo "[$PROG_NAME] Done."
