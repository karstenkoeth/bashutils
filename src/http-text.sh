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

PROG_NAME="http process text"
PROG_VERSION="0.08"
PROG_DATE="2021-03-02"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="http-text.sh"

# #########################################
#
# TODO
#
# PUT is for "Update Element". POST is for "Create Element".
# Therefore, the code should be changed.

# #########################################
#
# MIT license (MIT)
#
# Copyright 2021 - 2020 Karsten Köth
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
#   1: Text to log
function log()
{
    echo "[$PROG_SCRIPTNAME:$$:$actDateTime] $1" >> "$logFile"
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
    log "'$variable'" 

    # Typically, the first word should be "GET":
    connectionType=$(echo "$variable" | cut -f 1 -d " " -)
    log "Connection Type: '$connectionType'"
    documentPath=$(echo "$variable" | cut -f 2 -d " " -)
    log "Document Path:   '$documentPath'"
    httpVersion=$(echo "$variable" | cut -f 3 -d " " -)
    log "HTTP Version:    '$httpVersion'"

    # Typically, the header ends with an empty line. Therefore, we break with the first empty line:
    while read -r header; do
		header=${header%%$'\r'}
		[ -z "$header" ] && break
		log "$header"
        # For PUT, I need something like 'Content-Length: 9'
        headerVariable=$(echo "$header" | cut -d ":" -f 1 - )
        if [ "$headerVariable" = "Content-Length" ] ; then
            contentLength=$(echo "$header" | cut -d ":" -f 2 - | sed 's/^[ ]* \(.*\)/\1/' )
            log "Content-Length: '$contentLength'"
        fi
	done
}

# #########################################
# handleApi()
function handleApi()
{
    # Second level in api:
    apiCommand=$(echo "$documentPath" | cut -d "/" -f 3 -)
    #log "handleApi - secondLevel: '$apiCommand'"

    # addDoubleHead
    if   [ "$apiCommand" = "addDoubleHead" ] ; then
        Uuid=$(uuidgen)
        doubleHeadDir="$ProcessDir/$Uuid"
        mkdir -p "$doubleHeadDir"
        if [ -d "$doubleHeadDir" ] ; then
            touch "$doubleHeadDir/value.txt"
        else
            log "handleApi - addDoubleHead: Error creating directory. ($doubleHeadDir)"
            sendString "Error creating directory."
        fi
        if [ -f "$doubleHeadDir/value.txt" ] ; then
            log "handleApi - addDoubleHead: Exchange point created."
            sendString "{ \"DoubleHead\": \"$Uuid\" }"
        else
            log "handleApi - addDoubleHead: Error creating file. ($doubleHeadDir)"
            sendString "Error creating file."
        fi
    else
        log "handleApi: Error - Unknown Api Command."
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
    #log "handleData - secondLevel: '$doubleHead'"

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
    #log "handleData - subFolder: '$subFolder'"
    # Go on beyond security checks.
    valueFile="$ProcessDir/$doubleHead/$subFolder/value.txt"
    if [ -f "$valueFile" ] ; then
        if   [ "$connectionType" = "GET" ] ; then
            value=$(cat $valueFile)
            sendString "\"$value\""
            log "S->C: '$valueFile' : '$value' "
        elif [ "$connectionType" = "PUT" ] ; then
            variable=""
            if [ $contentLength -gt 0 ] ; then
                read -r -t 2 -n $contentLength variable 
            fi
            # Remove newline, ...:
            variable=${variable%%$'\r'}
            echo "$variable" > "$valueFile"
            log "C->S: '$variable' -> '$valueFile'"
        fi
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
    #log "handleGet - firstLevel: '$firstLevel'"

    # api - we support different commands
    if   [ "$firstLevel" = "api" ] ; then
        handleApi
    # doc - we show the documentation
    elif [ "$firstLevel" = "doc" ] ; then
        handleDoc
    # info - we show information about the settings
    elif [ "$firstLevel" = "info" ] ; then
        log "handleGet - info: Not yet supported."                  # TODO
    # data - we show the data
    elif [ "$firstLevel" = "data" ] ; then
        handleData
    else
        handleDoc
    fi
}

# #########################################
# handlePUT()
function handlePUT()
{
    # Look for the first level:
    # The first field is empty - we search for "/api/"
    firstLevel=$(echo "$documentPath" | cut -d "/" -f 2 -)
    #log "handlePut - firstLevel: '$firstLevel'"

    if [ "$firstLevel" = "data" ] ; then
        handleData
    fi
}

# #########################################
# handlePOST()
function handlePOST()
{
    # Look for the first level.
    log "handlePOST: Not yet supported."                            # TODO
}

# #########################################
#
# Main
#

# Start time:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
# Log file:
mkdir -p "$ServerDir"
logFile="$ServerDir/http-text.log"

log "Init..."

if [ $# -ge 1 ] ; then
    # log "Searching Process Directory '$1'"
    if [ -d "$1" ] ; then
        ProcessDir="$1"
        # log "Process Directory found."
    else
        log "Directory not accessible."
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

log "Done."
