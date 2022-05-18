#!/bin/bash

# #########################################
#
# Overview
#
# Helper program for script "executer.sh"

# #########################################
#
# Versions
#
# 2022-05-18 0.01 kdk First Version, derived from exec_test_a.sh. Tested on: System Type : LINUX + System Version : Raspbian GNU/Linux 9.13 (stretch)

PROG_NAME="executer test loop part"
PROG_VERSION="0.01"
PROG_DATE="2022-05-18"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="exec_test_l.sh"

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
# Copyright 2022 - 2021 Karsten Köth
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


# #########################################
#
# Constants
#

MainLoopResponseTime="1s"  # Response time of 1 second
MainLoopSleepFactor="5"    # Around 5 seconds on doing nothing
MainLoopTooLong="4"

# #########################################
#
# Variables
#

MainLoopCounter=0

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")


# #########################################
#
# Functions
#

# #########################################
# checkExit()
# Parameter
#    -
# Return Value
#    -
# Checks if the script should be terminated.
#
# ######## - WARNING - This is a reduced version of the script and NOT controlled via file system. - WARNING - ########
#
function checkExit()
{
    local counter=0
    while [ $counter -lt $MainLoopSleepFactor ] 
    do
        counter=$(expr $counter + 1)
        sleep "$MainLoopResponseTime"
        # If we run too long, the program should break the MainLoop:
        if [ $MainLoopCounter -gt $MainLoopTooLong ] ; then counter=$MainLoopSleepFactor; fi
    done
    MainLoopCounter=$(expr $MainLoopCounter + 1)
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
    else
        echo "[$PROG_NAME:ERROR] Unknown program parameter. Exit." ; exit;
    fi
fi

# Main loop:
while [ $MainLoopCounter -lt $MainLoopTooLong ]
do
    echo "[$PROG_NAME:STATUS] Running ..."
    checkExit
done

echo "[$PROG_NAME:STATUS] Done."
