#!/bin/bash

# #########################################
#
# Overview
#
# This script looks for the specific values of a device:
# - Used disk Space
# - CPU Usage
# - Memory Usage
# - Last Update 

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version
# 2020-12-20 0.02 kdk With actDateTime
# 2021-01-29 0.03 kdk 2021 year ready, with PROG_DATE and Copyright in help, with showVersion()
# 2021-02-08 0.04 kdk License text enhanced.
# 2021-08-10 0.05 kdk Device Monitor started.
# 2021-09-13 0.06 kdk Doing some tests and write comments

PROG_NAME="Device Monitor"
PROG_VERSION="0.06"
PROG_DATE="2021-09-13"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="devicemonitor.sh"

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
DISKSPACE="0%"
SYSTEM="unknown"
    # Allowed values:
    # - MACOSX
    # - WIN
    # - LINUX
    # - SUSE

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
# getSystem()
# Parameter
#    -
# Return Value
#    -
# Global Variable
#    SystemType - Change this global variable
function getSystem()
{
    # Check, if program is available:
    unamePresent=$(which uname)
    if [ -z "$unamePresent" ] ; then
        echo "[$PROG_NAME:ERROR] 'uname' not available. Exit"
        exit
    else
        sSYSTEM=$(uname -s) 
        # Detect System:
        echo "$sSYSTEM" # ########################################### DEBUG
        if [ "$sSYSTEM" == "Darwin" ] ; then
            SYSTEM="MACOSX"
        elif [ "$sSYSTEM" == "Linux" ] ; then
            SYSTEM="LINUX"
        else
            SYSTEM="Unknown"
        fi
    fi
}

# #########################################
# getDiskSpace()
# Parameter
#    -
# Return Value
#    -
function getDiskSpace()
{
    if [ "$SYSTEM" == "LINUX" ] ; then
        # Runs on Ubuntu 18.04.5:
        DISKSPACE=$(df -h / --output=pcent | tail -n 1)
    elif [ "$SYSTEM" == "MACOSX" ] ; then
        echo "TODO MACOSX"
    else
        echo "TODO"
    fi
}

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
    fi
fi

# Check, on which system we are running:
getSystem

# Do something ...
getDiskSpace

# Show Info:
echo "[$PROG_NAME:STATUS] Usage Disk Space : $DISKSPACE" 

# End:
echo "[$PROG_NAME] Done."
