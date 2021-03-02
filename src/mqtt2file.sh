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
# 2021-03-01 0.02 kdk With meaningful program parameter


PROG_NAME="mqtt2file"
PROG_VERSION="0.02"
PROG_DATE="2021-03-01"
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

# Program parameter
FLAT="0"

# #########################################
#
# Functions
#

# #########################################
# oneLevelMainLoop()
# Parameter
#    -
# Return Value
#    -
# Converts top level of topics into REST-API.
function oneLevelMainLoop()
{
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
    TmpDir="$HOME/tmp/http-echo_mqtt"
    TmpUuid="818c4143-11a0-4254-b22b-b0f2b9ddba55"
    # The file must be in same tree as created with "http-text.sh"
    # Only store non empty messages:
    if [ -n "$variable" ] ; then
        echo "$variable" > "$TmpDir/$TmpUuid/value.txt"
    else
        echo "[$PROG_NAME:DEBUG] Skip empty message ..."
    fi
  done
}

 #########################################
# multiLevelMainLoop()
# Parameter
#    -
# Return Value
#    -
# Converts multiple levels of topics into REST-API structure.
# Documentation
# Example für communication (start with: "mosquitto_sub -h localhost -d -t "prototype/#" "):
# Client mosqsub|3451-ip-172-31- sending CONNECT
# Client mosqsub|3451-ip-172-31- received CONNACK
# Client mosqsub|3451-ip-172-31- sending SUBSCRIBE (Mid: 1, Topic: #, QoS: 0)
# Client mosqsub|3451-ip-172-31- received SUBACK
# Subscribed (mid: 1): 0
# Client mosqsub|3438-ip-172-31- sending PINGREQ
# Client mosqsub|3438-ip-172-31- received PINGRESP
# Client mosqsub|3438-ip-172-31- sending PINGREQ
# Client mosqsub|3438-ip-172-31- received PINGRESP
# Client mosqsub|3451-ip-172-31- received PUBLISH (d0, q0, r0, m0, 'prototype/under', ... (23 bytes))
# A 4.under  data message
function multiLevelMainLoop()
{
    # Preparation before entering main loop:
    TmpDir="$HOME/tmp/http-echo_mqtt"                # TODO: Set as global variable
    TmpUuid="818c4143-11a0-4254-b22b-b0f2b9ddba55"   # TODO: Set as global variable
    TmpRoot="prototype"                              # TODO: Set as global variable

    # Main loop:
    while [ $endOfLoop -lt 1 ]
    do
        read -r variable 
        # Remove newline, ...:
        variable=${variable%%$'\r'}
        # Analyse content:
        testClient=$(echo "$variable" | cut -d " " -f 1 - )
        if [ "$testClient" = "Client" ] ; then
            testDirection=$(echo "$variable" | cut -d " " -f 3 -)
            echo "[$PROG_NAME:DEBUG] '$testDirection' (direction)"
            testCommand=$(echo "$variable" | cut -d " " -f 4 -)
            echo "[$PROG_NAME:DEBUG] '$testCommand' (command)"
            if [ "$testDirection" = "received" ] && [ "$testCommand" = "PUBLISH" ] ; then
                testData=$(echo "$variable" | cut -d "(" -f 2 -)
                testTopic=$(echo "$testData" | cut -d "'" -f 2 -)
                echo "[$PROG_NAME:DEBUG] '$variable' (line)"
                echo "[$PROG_NAME:DEBUG] '$testData' (data)"
                echo "[$PROG_NAME:DEBUG] '$testTopic' (topic)"
                # The next line contains the mqtt message:
                read -r mqttData
                # Remove newline, ...:
                mqttData=${mqttData%%$'\r'}
                echo "[$PROG_NAME:DEBUG] '$mqttData' (message)"
                # TODO Write into correct file into correct folder path. Therefore create folder(s) mkdir -p
                # Do not accept "." as folder or topic content. 
                testChar=$(echo "$testTopic" | grep "\.")
                if [ -n "$testChar" ] ; then
                    # Topic contains minimum one point. Set to standard:
                    testTopic="$TmpRoot/ignored"
                    echo "[$PROG_NAME:DEBUG] '$testTopic' (topic corrected)"
                fi
                # Do not accept "\" as folder or topic content. 
                testChar=$(echo "$testTopic" | grep "\\\\")
                if [ -n "$testChar" ] ; then
                    # Topic contains minimum one backslash. Set to standard:
                    testTopic="$TmpRoot/ignored"
                    echo "[$PROG_NAME:DEBUG] '$testTopic' (topic corrected)"
                fi                
                if [ -n "$mqttData" ] ; then
                    if [ ! -d "$TmpDir/$TmpUuid/$testTopic/" ] ; then
                        mkdir -p "$TmpDir/$TmpUuid/$testTopic/"
                    fi
                    echo "$mqttData" > "$TmpDir/$TmpUuid/$testTopic/value.txt"
                    echo "[$PROG_NAME:DEBUG] Message stored under '$TmpDir/$TmpUuid/$testTopic/value.txt'"
                else
                    echo "[$PROG_NAME:DEBUG] Skip empty message ..."
                fi
            fi # END of Command=PUBLISH
        fi # END of command line
    done
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
    echo "    -f     : Support flat mqtt topic structure"
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
    elif [ "$1" = "-f" ] ; then
        FLAT="1"
    else
        echo "[$PROG_NAME:WARNING] Program parameter '$1' unknown."
    fi
fi

# Main loop:

endOfLoop=0

echo "[$PROG_NAME:STATUS] Entering main loop..."

if [ "$FLAT" = "1" ] ; then
    oneLevelMainLoop
else
    multiLevelMainLoop
fi

echo "[$PROG_NAME:STATUS] Done."
