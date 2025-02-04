#!/bin/bash

# #########################################
#
# Overview
#

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version with version information
# 2020-12-20 0.02 kdk With Port as parameter
# 2020-12-21 0.03 kdk With CORS in http header
# 2020-12-22 0.04 kdk Kill optimized to catch all
# 2021-02-26 0.05 kdk Prepared for MQTT
# 2021-03-01 0.06 kdk Debugging ...
# 2021-03-02 0.08 kdk Prepared for continuous run
# 2021-11-09 0.09 kdk Demo mode
# 2022-11-30 0.10 kdk More general
# 2024-10-19 0.11 kdk Log() included
# 2025-01-27 0.12 kdk Preparation for Time Series Server
# 2025-02-04 0.13 kdk Log outputs adapted

PROG_NAME="HTTP Echo"
PROG_VERSION="0.13"
PROG_DATE="2025-02-04"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="http-echo.sh"

# #########################################
#
# MIT license (MIT)
#
# Copyright 2025 - 2020 Karsten Köth
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

product="http-echo"

# #########################################
#
# Variables
#

PORT="11883"
DEMOPORT="8089"
MQTT="0"
DEMO="0"
SERVER="http-text.sh"
INSTANCE=""

ServerDir="$HOME/tmp"
logFile=""


# #########################################
#
# Functions
#

# #########################################
# log()
# Parameter
#   1: Text to log
function log()
{
    actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
    echo "[$PROG_SCRIPTNAME:$$:$actDateTime] $1" >> "$logFile"
}

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
        log "[getSharingDirectory:STATUS] Instance set to '$Uuid'."
    fi
    log "[getSharingDirectory:TmpDir:DEBUG] '$TmpDir' defined."
    mkdir -p "$TmpDir"
    if [ ! -d "$TmpDir" ] ; then
        echo "[$PROG_NAME:getSharingDirectory:ERROR] Can't create temporary directory. Exit."
        log             "[getSharingDirectory:ERROR] Can't create temporary directory. Exit."
        exit
    fi   
    log "[getSharingDirectory:TmpDir:DEBUG] '$TmpDir' created."
    echo "$TmpDir"
}

# #########################################
# setSharingDirectory()
# Parameter
#   1: Instance UUID
# Return
#   1 : Existing sharing directory
# Get directory for sharing.
function setSharingDirectory()
{
    TmpDir="$HOME/tmp/$product""_$1"
    
    log "[setSharingDirectory:TmpDir:DEBUG] '$TmpDir' defined."
    if [ ! -d "$TmpDir" ] ; then
        echo "[$PROG_NAME:setSharingDirectory:ERROR] Can't use temporary directory. Exit."
        log             "[setSharingDirectory:ERROR] Can't use temporary directory. Exit."
        exit
    fi   
    log "[setSharingDirectory:TmpDir:DEBUG] '$TmpDir' checked."
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
        echo "[$PROG_NAME:serverText:ERROR] Server process script not found. Exit."
        log             "[serverText:ERROR] Server process script not found. Exit."
        exit
    fi
    log "[serverText:ServerScript:DEBUG] '$0'  '$ServerScript'"    

    if [ -z "$INSTANCE" ] ; then
        SharingDir=$(getSharingDirectory)
    else
        SharingDir=$(setSharingDirectory "$INSTANCE")
    fi
    log "[serverText:SharingDir:DEBUG] '$SharingDir'"

    socat TCP-L:$serverPort,fork EXEC:"$ServerScript $SharingDir"
    # socat -d -d TCP-L:$serverPort,fork EXEC:"$ServerScript $SharingDir"
}


# #########################################
# serverSimple()
# Parameter
#   1 : Port number listen at
# Return 
#    -
# This function starts a simple server not needing any additional files.
function serverSimple()
{
    serverPort="$1"
    # bash echo
    #socat -T 1 -d -d TCP-L:10081,reuseaddr,fork,crlf SYSTEM:"echo -e \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""

    # bsd echo, e.g. on MAC:
    socat -T 1 -d -d TCP-L:$serverPort,reuseaddr,fork,crlf SYSTEM:"echo \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\nAccess-Control-Allow-Origin: *\\\n\\\ndate: \$\(date\)\\\nserver: \$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo \"\\\"\\\n\\\"\""
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
                echo "[$PROG_NAME:killProcesses:STATUS] '$killProc' killed."
                log             "[killProcesses:STATUS] '$killProc' killed."
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
    echo "    -V      : Show Program Version"
    echo "    -h      : Show this help"
    echo "    -k      : Kill all '$PROG_SCRIPTNAME' processes"
    echo "    -d      : Support demo mode with fixed starting directory and port $DEMOPORT"
    echo "    -m      : Support mqtt2rest program with fixed starting directory and port $PORT"
    echo "    -p 80   : Define the port listen at. (e.g. port 80)."
    echo "    -i uuid : Define the existing instance which should be used."
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

# Log file:
mkdir -p "$ServerDir"
logFile="$ServerDir/$product.log"

log "Init..."


# Check for program parameters:
if [ $# -ge 1 ] ; then
    if [ "$1" = "-p" ] ; then
        if [ $# -ge 2 ] ; then
            isNumber "$2"
            if [ $? -eq 0 ] ; then
                PORT="$2"
                echo "[$PROG_NAME:Main:STATUS] Port set to '$PORT'."
                log             "[Main:STATUS] Port set to '$PORT'."
            fi
            # Port checked, maybe instance is also given...
            if [ $# -ge 4 ] ; then
                if [ "$3" = "-i" ] ; then
                    INSTANCE="$4"
                    echo "[$PROG_NAME:Main:STATUS] Instance set to '$INSTANCE'."
                    log             "[Main:STATUS] Instance set to '$INSTANCE'."
                fi
            fi
        fi
    elif [ "$1" = "-i" ] ; then
        if [ $# -ge 2 ] ; then
            INSTANCE="$2"
            echo "[$PROG_NAME:Main:STATUS] Instance set to '$INSTANCE'."
            log             "[Main:STATUS] Instance set to '$INSTANCE'."
            # Instance checked, maybe port is also given...
            if [ $# -ge 4 ] ; then
                if [ "$3" = "-p" ] ; then
                    isNumber "$4"
                    if [ $? -eq 0 ] ; then
                        PORT="$4"
                        echo "[$PROG_NAME:Main:STATUS] Port set to '$PORT'."
                        log             "[Main:STATUS] Port set to '$PORT'."
                    fi
                fi
            fi
        fi
    elif [ "$1" = "-k" ] ; then
        killServer ; exit;
    elif [ "$1" = "-m" ] ; then
        MQTT="1"
    elif [ "$1" = "-d" ] ; then
        DEMO="1"
        PORT="$DEMOPORT"
    elif [ "$1" = "-P" ] ; then
        echo "ProgramName=$product" ; exit;
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

# Old style:
#serverSimple $PORT

serverText $PORT

log "Done."
echo "[$PROG_NAME:STATUS] Done."
