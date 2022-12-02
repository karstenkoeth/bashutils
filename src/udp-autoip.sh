#!/bin/bash

# #########################################
#
# Overview
#

# #########################################
#
# Versions
#
# 2022-12-02 0.01 kdk First version derived from http-text.sh version 0.09

PROG_NAME="udp autoip"
PROG_VERSION="0.01"
PROG_DATE="2022-12-02"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="udp-autoip.sh"

# #########################################
#
# TODO
#


# #########################################
#
# Hints
#
# Binary output
# See: https://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format
# See: https://unix.stackexchange.com/questions/118247/echo-bytes-to-a-file
#     Get: echo -n -e '\x66\x6f\x6f'


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

product="udp-autoip"


# #########################################
#
# Variables
#

ServerDir="$HOME/tmp"
logFile=""
ProcessDir=""
DataDir=""


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
# receiveTelegram()
function receiveTelegram()
{
    # First, look for the first line from client.
    read -r variable 
    # Remove newline, ...:
    variable=${variable%%$'\r'}
    log "'$variable'" 

    # Typically, the header ends with an empty line. Therefore, we break with the first empty line:
    while read -r header; do
		header=${header%%$'\r'}
		[ -z "$header" ] && break
		log "$header"
	done
}

# #########################################
# sendTelegram()
function sendTelegram()
{
    echo -n -e '\x90\x00' # RPL_NETSCAN
    echo -n -e '\x00\x00' # Length of Data
    # ...
    echo -n -e "$actDateTime"
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

log "Init '$PROG_NAME ($PROG_CLASS) $PROG_VERSION' ..."

if [ $# -ge 1 ] ; then
    # log "Searching Process Directory '$1'"
    if [ -d "$1" ] ; then
        ProcessDir="$1"
        # log "Process Directory found."
    else
        log "Directory not accessible."
    fi
fi

receiveTelegram
sendTelegram

log "Done."
