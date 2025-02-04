#!/bin/bash

# #########################################
#
# Overview
#

# #########################################
#
# Versions
#
# 2020-12-21 0.01 kdk First Version
# 2020-12-22 0.02 kdk Version with api and data
# 2020-12-22 0.03 kdk After writng the Readme.md: Added the handleDoc feature.
# 2021-02-26 0.04 kdk With comments
# 2021-03-01 0.06 kdk Debugging ...
# 2021-03-02 0.07 kdk Debugging ...
# 2021-03-02 0.08 kdk Prepared for continuous run
# 2022-11-30 0.09 kdk More general
# 2024-10-18 0.10 kdk More logs
# 2025-01-27 0.11 kdk Preparation for Time Series Server
# 2025-02-04 0.12 kdk Preparation for Time Series Server
# 2025-02-04 0.13 kdk Preparation for Time Series Server, tested

PROG_NAME="http process text"
PROG_VERSION="0.13"
PROG_DATE="2025-02-04"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="http-text.sh"

# #########################################
#
# TODO
#
# PUT is for "Update Element". POST is for "Create Element".
# Therefore, the code should be changed.
#
#
# Time Series
#
# POST
# Create an uuid for the specific time serie (e.g. for time serie "Temperature IT Room")
#
# PUT value as data to the path /timeseries/$UUID/
# Data could be one number or a complexe string
# E.g.:
# data = "1"
# data = "1234"    <-- One column containing an integer number
# data = "123,456" <-- Two column: First column contains '123', second column contains '456'.
# data = "12.3"    <-- One column containing a float number
# Data is only be allowed to be a number. The data value should be showable in a diagram as value point.
# Time Series:
# The server itself adds the data and time of the timestamp receiving the value to this value.
#
# GET values as data from path /timeseries/$UUID/

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

product="http-text"


# #########################################
#
# Variables
#

ServerDir="$HOME/tmp"
logFile=""
ProcessDir=""
DataDir=""

# Process Variables
connectionType=""
documentPath=""
httpVersion=""

# http Header Content:
contentLength=""


# #########################################
#
# Functions
#

# #########################################
# log()
# Parameter
#   1: Function inside log is called
#   2: Text to log
function log()
{
    actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
    echo "[$PROG_SCRIPTNAME:$$:$actDateTime:$1] $2" >> "$logFile"
}

# #########################################
# warn()
# Parameter
#   1: Function inside warn is called
#   2: Text to log
function warn()
{
    actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
    echo "[$PROG_SCRIPTNAME:$$:$actDateTime:$1:WARNING] $2" >> "$logFile"
}

# #########################################
# deb()
# Parameter
#   1: Function inside deb is called
#   2: Text to log
function deb()
{
    actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
    echo "[$PROG_SCRIPTNAME:$$:$actDateTime:$1:DEBUG] $2" >> "$logFile"
}

# #########################################
# sendString()
function sendString()
{
    printf '%s\r\n' "$*";
}

# #########################################
# sendHeader()
function sendHeader()
{
    echo "HTTP/1.0 200 OK"
    echo "DocumentType: text/plain"        # Maybe, we have to send: "application/json"
    echo "Access-Control-Allow-Origin: *"
    echo ""
}

# #########################################
# sendGreetings()
function sendGreetings()
{
    echo "Welcome to my plain text."
    echo "Nice to see you."
    echo ""
    echo ""
}


# #########################################
# receiveHeader()
function receiveHeader()
{
    # First, look for the first line from client. GET or POST or PUT
    read -r variable 
    # Remove newline, ...:
    variable=${variable%%$'\r'}
    log "receiveHeader" "'$variable'" 

    # Typically, the first word should be "GET":
    connectionType=$(echo "$variable" | cut -f 1 -d " " -)
    log "receiveHeader" "Connection Type: '$connectionType'"
    documentPath=$(echo "$variable" | cut -f 2 -d " " -)
    log "receiveHeader" "Document Path:   '$documentPath'"
    httpVersion=$(echo "$variable" | cut -f 3 -d " " -)
    log "receiveHeader" "HTTP Version:    '$httpVersion'"

    # Typically, the header ends with an empty line. Therefore, we break with the first empty line:
    while read -r header; do
		header=${header%%$'\r'}
		[ -z "$header" ] && break
		deb "receiveHeader" "$header"
        # For PUT, I need something like 'Content-Length: 9'
        headerVariable=$(echo "$header" | cut -d ":" -f 1 - )
        if [ "$headerVariable" = "Content-Length" ] ; then
            contentLength=$(echo "$header" | cut -d ":" -f 2 - | sed 's/^[ ]* \(.*\)/\1/' )
            log "receiveHeader" "Content-Length: '$contentLength'"
        fi
	done
}

# #########################################
# handleApi()
function handleApi()
{
    # Second level in api:
    apiCommand=$(echo "$documentPath" | cut -d "/" -f 3 -)
    deb "handleApi" "SecondLevel: '$apiCommand'"

    # addDoubleHead
    if   [ "$apiCommand" = "addDoubleHead" ] ; then
        Uuid=$(uuidgen)
        doubleHeadDir="$ProcessDir/$Uuid"
        mkdir -p "$doubleHeadDir"
        if [ -d "$doubleHeadDir" ] ; then
            touch "$doubleHeadDir/value.txt"
        else
            warn "handleApi:addDoubleHead" "Error creating directory. ($doubleHeadDir)"
            sendString "Error creating directory."
        fi
        if [ -f "$doubleHeadDir/value.txt" ] ; then
            log "handleApi:addDoubleHead" "Exchange point created."
            sendString "{\"DoubleHead\":\"$Uuid\"}"
        else
            warn "handleApi:addDoubleHead" "Error creating file. ($doubleHeadDir/value.txt)"
            sendString "Error creating file."
        fi
    elif [ "$apiCommand" = "addTimeSeries" ] ; then
        tsUuid=$(uuidgen)
        timeSeriesDir="$ProcessDir/$tsUuid"
        mkdir -p "$timeSeriesDir"
        if [ -d "$timeSeriesDir" ] ; then
            touch "$timeSeriesDir/values.csv"
        else
            warn "handleApi:addTimeSeries" "Error creating directory. ($timeSeriesDir)"
            sendString "Error creating directory."
        fi
        if [ -f "$timeSeriesDir/values.csv" ] ; then
            log "handleApi:addTimeSeries" "Exchange point created."
            sendString "{\"TimeSeries\":\"$tsUuid\"}"
        else
            log "handleApi:addTimeSeries" "Error creating file. ($timeSeriesDir/values.csv)"
            sendString "Error creating file."
        fi
    else
        warn "handleApi" "Error - Unknown Api Command '$apiCommand'."
    fi
}

# #########################################
# handleData()
function handleData()
{
    # Second level in data: We check, if the uuid is known:
    doubleHead=$(echo "$documentPath" | cut -d "/" -f 3 -)
    # TODO: For GET and PUT we must care about a non evil content of "doubleHead". 
    # Only allowed are numbers, letters and '-'.
    deb "handleData" "secondLevel: '$doubleHead'"

    # In documentPath, we have the correct path. E.g.:
    # '/data/818c4143-11a0-4254-b22b-b0f2b9ddba55/prototype/' # With or without trailing slash!
    # First Element is "data" and is checked in code before here.
    # Second Element is UUID and is checked in code before here.
    subFolder=${documentPath/\/data\/$doubleHead}
    # Do not accept "." as folder or topic content. 
    testChar=$(echo "$documentPath" | grep "\.")
    if [ -n "$testChar" ] ; then
        # Topic contains minimum one point. Set to standard:
        subFolder=""
    fi
    # Do not accept "\" as folder or topic content. 
    testChar=$(echo "$documentPath" | grep "\\\\")
    if [ -n "$testChar" ] ; then
        # Topic contains minimum one backslash. Set to standard:
        subFolder=""
    fi                
    deb "handleData" "subFolder: '$subFolder'"
    # Go on beyond security checks.
    valueFile="$ProcessDir/$doubleHead/$subFolder/value.txt"
    if [ -f "$valueFile" ] ; then
        if   [ "$connectionType" = "GET" ] ; then
            value=$(cat $valueFile)
            sendString "\"$value\""
            log "handleData" "S->C: '$valueFile' : '$value' "
        elif [ "$connectionType" = "PUT" ] ; then
            variable=""
            if [ $contentLength -gt 0 ] ; then
                read -r -t 2 -n $contentLength variable 
            fi
            # Remove newline, ...:
            variable=${variable%%$'\r'}
            echo "$variable" > "$valueFile"
            log "handleData" "C->S: '$variable' -> '$valueFile'"
        fi
    fi
}

# #########################################
# handleTimeSeries()
function handleTimeSeries()
{
    # Second level in data: We check, if the uuid is known:
    timeSeries=$(echo "$documentPath" | cut -d "/" -f 3 -)
    log "handleTimeSeries" "TimeSeries: '$timeSeries'"
    # TODO: For GET, POST and PUT we must care about a non evil content of "timeSeries". 
    # Only allowed are numbers, letters and '-'.

    # In documentPath, we have the correct path. E.g.:
    # '/data/818c4143-11a0-4254-b22b-b0f2b9ddba55/prototype/' # With or without trailing slash!
    # First Element is "timeseries" and is checked in code before here.
    # Second Element is UUID and is checked in code before here.
    tsSubFolder=${documentPath/\/timeseries\/$timeSeries}
    # Do not accept "." as folder or topic content. 
    local testChar
    testChar=$(echo "$documentPath" | grep "\.")
    if [ -n "$testChar" ] ; then
        # Topic contains minimum one point. Set to standard:
        tsSubFolder=""
    fi
    # Do not accept "\" as folder or topic content. 
    testChar=$(echo "$documentPath" | grep "\\\\")
    if [ -n "$testChar" ] ; then
        # Topic contains minimum one backslash. Set to standard:
        tsSubFolder=""
    fi                
    # Maybe a trailing '/' is added, we will remove it:
    if [ "$tsSubFolder" = "/" ] ; then
        tsSubFolder=""
    fi
    deb "handleTimeSeries" "subFolder: '$tsSubFolder'"
    # Go on beyond security checks.
    local tsValueFile
    
    if [ -z "$subFolder" ] ; then
        tsValueFile="$ProcessDir/$timeSeries/values.csv"
    else
        tsValueFile="$ProcessDir/$timeSeries/$tsSubFolder/values.csv"
    fi

    if [ -f "$tsValueFile" ] ; then
        if   [ "$connectionType" = "GET" ] ; then
            local tsValue
            tsValue=$(cat $tsValueFile)
            sendString "$tsValue"
            log "handleTimeSeries" "S->C: '$tsValueFile' : '$tsValue' "
        elif [ "$connectionType" = "POST" ] ; then
            warn "handleTimeSeries" "Connection Type '$connectionType' not supported for data transfer. Use an api command to create a time serie."
        elif [ "$connectionType" = "PUT" ] ; then
            local tsVariable
            tsVariable=""
            if [ $contentLength -gt 0 ] ; then
                read -r -t 2 -n $contentLength tsVariable 
                # Remove newline, ...:
                tsVariable=${tsVariable%%$'\r'}
                local tsActDate
                local tsActTime
                tsActDate=$(date "+%Y-%m-%d") 
                tsActTime=$(date "+%H:%M:%S")
                echo "$tsActDate,$tsActTime,$tsVariable" >> "$tsValueFile"
                log "handleTimeSeries" "C->S: '$tsVariable' -> '$tsValueFile'"
            else
                warn "handleTimeSeries" "Connection Type '$connectionType' without content length"
            fi
        else
            warn "handleTimeSeries" "Connection Type '$connectionType' not supported."
        fi
    else
        warn "handleTimeSeries" "File not found '$tsValueFile'."
    fi
}

# #########################################
# handleDoc()
function handleDoc()
{
    sendString "Get source code at https://github.com/karstenkoeth/bashutils.git"
}

# #########################################
# handleGET()
function handleGET()
{
    # Look for the first level:
    # The first field is empty - we search for "/api/"
    firstLevel=$(echo "$documentPath" | cut -d "/" -f 2 -)
    deb "handleGET" "firstLevel: '$firstLevel'"

    # api - we support different commands
    if   [ "$firstLevel" = "api" ] ; then
        handleApi
    # doc - we show the documentation
    elif [ "$firstLevel" = "doc" ] ; then
        handleDoc
    # info - we show information about the settings
    elif [ "$firstLevel" = "info" ] ; then
        log "handleGET" "Section 'info' not yet supported."                  # TODO
    # data - we show the data
    elif [ "$firstLevel" = "data" ] ; then
        handleData
    elif [ "$firstLevel" = "timeseries" ] ; then
        handleTimeSeries
    else
        handleDoc
    fi
}

# #########################################
# handlePUT()
function handlePUT()
{
    # Look for the first level:
    # The first field is empty - we search for "/data/"
    firstLevel=$(echo "$documentPath" | cut -d "/" -f 2 -)
    deb "handlePUT" "firstLevel: '$firstLevel'"

    if [ "$firstLevel" = "data" ] ; then
        handleData
    elif [ "$firstLevel" = "timeseries" ] ; then
        handleTimeSeries
    fi
}

# #########################################
# handlePOST()
function handlePOST()
{
    # Look for the first level:
    # The first field is empty - we search for "/timeseries/"
    firstLevel=$(echo "$documentPath" | cut -d "/" -f 2 -)
    deb "handlePOST" "firstLevel: '$firstLevel'"

    if   [ "$firstLevel" = "api" ] ; then
        handleApi
    elif [ "$firstLevel" = "timeseries" ] ; then
        handleTimeSeries
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
    echo "   DIR     : Work with Process Directory DIR"
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

# Start time:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
# Log file:
mkdir -p "$ServerDir"
logFile="$ServerDir/$product.log"

log "Main" "Init..."

if [ $# -ge 1 ] ; then
    if [ "$1" = "-V" ] ; then
        showVersion ; log "Main" "Show version..." ; log "Main" "Done." ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; log "Main" "Show help..." ; log "Main" "Done." ; exit;
    elif [ -d "$1" ] ; then
        ProcessDir="$1"
        log "Main" "Process Directory '$1' found."
    else
        log "Main" "Process Directory '$1' not accessible."
    fi
fi

sendHeader
receiveHeader

if   [ "$connectionType" = "GET" ] ; then
    handleGET
elif [ "$connectionType" = "PUT" ] ; then
    handlePUT
elif [ "$connectionType" = "POST" ] ; then
    handlePOST
fi

# sendGreetings

log "Main" "Done."
