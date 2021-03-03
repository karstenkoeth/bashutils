#!/bin/bash

# #########################################
#
# Overview
#
# This script provides a mqtt to rest translator.
# See: 
#  - bashutils/http-echo.sh + bashutils/http-text.sh = rest part
#  - bashutils/mqtt2file.sh = mqtt part

# #########################################
#
# Installation
#
# A mqtt broker, e.g. mosquitto must be installed and running on localhost

# #########################################
#
# Versions
#
# 2021-02-26 0.01 kdk First Version derived from bashutils/bash-script-template.sh
# 2021-03-01 0.02 kdk Debugging ...
# 2021-03-02 0.08 kdk Prepared for continuous run
# 2021-03-03 0.09 kdk TODO added

PROG_NAME="mqtt2rest"
PROG_VERSION="0.09"
PROG_DATE="2021-03-03"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="mqtt2rest.sh"

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
# Load Test
#
#
# Running on ec2 t2.micro eu-central-1b Ubuntu 18.04.5 LTS (GNU/Linux 5.4.0-1032-aws x86_64):
# 10 instances of mqtt-test.sh with 0.5 s delay
# 10 instances of rest-test.sh with 0.5 s delay
# 1 instance of mosquitto broker
# 1 instance of mqtt2rest
# 1 instance of top with 0.5 s delay
# 1 instance of mosquitto_sub: mosquitto_sub -h localhost -t "#"
# 8 ssh sessions open
# 
# Running on TDC-E IoT device
# 1 instance of NodeRed with 1 s delay publishing 1 message 
#
# --> cpu load: 30 ... 50 / 50 ... 64 [us/sy]
#
#
# Same setting but increased instances of test scripts:
# 20 mqtt-tests + 10 rest-tests --> 40 ... 50 us
#
# Same setting but increased instances of test scripts:
# 20 mqtt-tests + 20 rest-tests --> 40 ... 50 us, around 220 tasks total, around 140k Mem free
#
# Same setting but without instances of test scripts, without mqtt2rest, without mosquitto_sub:
# --> 0.0 ... 2.0 / 0.0 ...2.0 [us/sy], 122 tasks total, around 188k Mem free


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
    if [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:WARNING] Program parameter '$1' unknown."
    fi
fi

# Init ####################

# TODO
# Check, if mqtt cli is accessable
# Check if mqtt broker is running on localhost: Publish something and subscribe to it
# If not: try to start or exit. Maybe create standard configuration file. Or do it in install script.

# Main part ###############

# Start rest part:
http-echo.sh -m &                                          # TODO: Zeile freischalten nach Test.

# Start mqtt part:
# mosquitto_sub -h localhost -t prototype | mqtt2file.sh -f # Flat topics
mosquitto_sub -h localhost -d -t "prototype/#" | mqtt2file.sh # Structured topics

echo "[$PROG_NAME] Done."
