#!/bin/bash

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version with version information
# 2020-12-20 0.02 kdk With Port as parameter

PROG_NAME="HTTP Echo"
PROG_VERSION="0.02"
PROG_SCRIPTNAME="http-echo.sh"

# #########################################
#
# MIT license (MIT)
#
# Copyright 2020 Karsten Köth
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


# #########################################
#
# Variables
#

PORT="10081"


# #########################################
#
# Functions
#


# #########################################
# killProcesses()
# Parameter
#    -
# Return 
#    -
# Kill all processes regarding this program
function killProcesses()
{
    # Kill all processes with this batch script name:
    killMe=$(ps x | grep http-echo.sh | cut -f 1 -d " ")
    for killProc in $killMe
    do
        # Do NOT kill myself!
        if [ $$ -ne $killProc ] ; then
            kill $killProc
            echo "[$PROG_NAME:STATUS] '$killProc' killed."
        fi
    done
    # Kill all processes from socat with this program parameter inside the script:
    killMe2=$(ps x | grep socat | grep DocumentType | cut -f 1 -d " ")
    for killProc2 in $killMe2
    do
        kill $killProc2
        echo "[$PROG_NAME:STATUS] '$killProc2' killed."
    done
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
    echo "    -h     : Show this help"
    echo "    -k     : Kill all '$PROG_SCRIPTNAME' processes"
    echo "    -p 80  : Define the port listen at. (e.g. port 80)."
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
        killProcesses ; exit;
    elif [ "$1" = "-V" ] ; then
        echo "[$PROG_NAME:STATUS] Version $PROG_VERSION" ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi


# bash echo
#socat -T 1 -d -d TCP-L:10081,reuseaddr,fork,crlf SYSTEM:"echo -e \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""

# bsd echo, e.g. on MAC:
socat -T 1 -d -d TCP-L:$PORT,reuseaddr,fork,crlf SYSTEM:"echo \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver: \$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""

echo "[$PROG_NAME:STATUS] Done."
