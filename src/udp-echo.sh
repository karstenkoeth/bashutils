#!/bin/bash

# #########################################
#
# Overview
#

# #########################################
#
# Versions
#
# 2022-11-30 0.01 kdk Derived from http-echo.sh version 0.10

PROG_NAME="UDP Echo"
PROG_VERSION="0.01"
PROG_DATE="2022-11-30"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="udp-echo.sh"

# #########################################
#
# MIT license (MIT)
#
# Copyright 2022 - 2020 Karsten Köth
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
# Constants
#

product="udp-echo"

# #########################################
#
# Variables
#

PORT="30718"
DEMOPORT="8089"
MQTT="0"
DEMO="0"
SERVER="udp-text.sh"
DEBUG="0"

# #########################################
#
# Functions
#


# #########################################
# getSharingDirectory()
# Parameter
#   -
# Return
#   1 : Newly created sharing directory
# Get directory for sharing.
function getSharingDirectory()
{
    if [ "$MQTT" = "1" ] ; then
        TmpDir="$HOME/tmp/$product""_mqtt"
    elif [ "$DEMO" = "1" ] ; then
        TmpDir="$HOME/tmp/$product""_demo"
    else
        Uuid=$(uuidgen)
        TmpDir="$HOME/tmp/$product""_$Uuid"
    fi
    mkdir -p -v "$TmpDir"
    if [ ! -d "$TmpDir" ] ; then
        echo "[$PROG_NAME:ERROR] Can't create temporary directory. Exit."
        exit
    fi   
    echo "$TmpDir"
}

# #########################################
# serverText()
# Parameter
#   1 : Port number listen at
# Return 
#    -
# This function starts the server for sending Content-Type: application/text
function serverText()
{
    serverPort="$1"
    serverProcess="$SERVER"
    BinaryDir=$(dirname "$0")
    ServerScript="$BinaryDir/$serverProcess"
    if [ ! -f "$ServerScript" ] ; then
        echo "[$PROG_NAME:ERROR] Server process script not found. Exit."
        exit
    fi
    #echo "[$PROG_NAME:serverText:ServerScript:DEBUG] '$0'  '$ServerScript'"    

    SharingDir=$(getSharingDirectory)
    #echo "[$PROG_NAME:serverText:SharingDir:DEBUG] '$SharingDir'"

    if [ "$DEBUG" = "0" ] ; then
        socat UDP4-RECVFROM:$serverPort,broadcast,fork EXEC:"$ServerScript $SharingDir"
    else
        # With debug output:
        socat -d -d UDP4-RECVFROM:$serverPort,broadcast,fork EXEC:"$ServerScript $SharingDir" 
    fi
}

# #########################################
# killProcesses()
# Parameter
#    1 : String (maybe with more lines) holding all PIDs
# Return
#    -
# Kill all processes mentioned in the parameter
function killProcesses()
{
    killProc=""
    for killProc in $1
    do
        # Do NOT kill myself!
        if [ $$ -ne $killProc ] ; then
            # Only kill, if the process still runs (exclude grep, etc...)
            runProc=$(ps -o pid=,command= $killProc)
            if [ -n "$runProc" ] ; then
                kill $killProc
                echo "[$PROG_NAME:STATUS] '$killProc' killed."
            fi
        fi
    done
}

# #########################################
# killServer()
# Parameter
#    -
# Return 
#    -
# Kill all processes regarding this program
function killServer()
{
    # Kill all processes with this batch script name:
    killMe=$(ps x -o pid,command | grep $product.sh | sed 's/^[ ]* \(.*\)/\1/' | cut -f 1 -d " ")
    killProcesses "$killMe"

    # Kill all processes from socat with this program parameter inside the script:
    # serverSimple
    killMe=$(ps x -o pid,command | grep socat | grep DocumentType | sed 's/^[ ]* \(.*\)/\1/' | cut -f 1 -d " ")
    killProcesses "$killMe"

    # serverText
    killMe=$(ps x -o pid,command | grep socat | grep $SERVER | sed 's/^[ ]* \(.*\)/\1/' | cut -f 1 -d " ")
    killProcesses "$killMe"
}

# #########################################
# isNumber()
# Parameter
#  1  : String to check
# Return Value
#  1  : '0' = is number
# Check, if the string contains only digits.
# Example
#   isNumber "12345"
#   if [ $? -eq 0 ] ; then
#     echo "Is number"
#   fi
function isNumber()
{
case $1 in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
esac
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
    echo "    -D     : Switch debug mode on"
    echo "    -h     : Show this help"
    echo "    -k     : Kill all '$PROG_SCRIPTNAME' processes"
    echo "    -d     : Support demo mode with fixed starting directory and port $DEMOPORT"
    echo "    -m     : Support mqtt2rest program with fixed starting directory and port $PORT"
    echo "    -p 80  : Define the port listen at. (e.g. port 80)."
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
if [ $# -ge 1 ] ; then
    if [ "$1" = "-p" ] ; then
        if [ $# -eq 2 ] ; then
            isNumber "$2"
            if [ $? -eq 0 ] ; then
                PORT="$2"
                echo "[$PROG_NAME:STATUS] Port set to '$PORT'."
            fi
        fi
    elif [ "$1" = "-k" ] ; then
        killServer ; exit;
    elif [ "$1" = "-m" ] ; then
        MQTT="1"
    elif [ "$1" = "-d" ] ; then
        DEMO="1"
        PORT="$DEMOPORT"
    elif [ "$1" = "-D" ] ; then
        DEBUG="1"
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

serverText $PORT

echo "[$PROG_NAME:STATUS] Done."
