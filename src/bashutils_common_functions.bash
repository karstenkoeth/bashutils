# #########################################
#
# Overview
#
# This is an bash script include file.
# This file is used by:
#  - image_viewer_server.sh as image_viewer_common_func.bash
#  - html_collect_pictures.sh as image_viewer_common_func.bash
#  - bash-script-template.sh as bashutils_common_functions.bash 
#
#
# Usage
#
# Include this in a shell script:
#PROG_LIBRARYNAME="bashutils_common_functions.bash"
#FunctionLibrary="$SourceDir/$PROG_LIBRARYNAME"
#if [ ! -f "$FunctionLibrary" ] ; then
#    echo "[$PROG_NAME:WARNING] Function Library not found. Exit."
#    exit
#else
#    source "$FunctionLibrary"
#    echod "Main" "Function Library found."
#fi
#
#
# Links
#
# https://www.gnu.org/software/bash/manual/html_node/index.html  - Abstract descriptions


# #########################################
#
# Versions
#
# 2018-04-06 0.01 kdk First version
# 2018-05-21 0.10 kdk With license text.
# 2020-12-17 0.20 kdk Renamed from image_viewer_common_func.bash to bashutils_common_functions.bash
# 2020-12-20 0.21 kdk With is Number from http-echo.sh
# 2021-01-29 0.22 kdk With updateLog, ... from swsCosts
# 2021-04-11 0.23 kdk With function deleteQuotationMark()
# 2021-11-17 0.24 kdk With checkOrCreateFile()
# 2021-11-18 0.25 kdk With random()
# 2022-02-04 0.26 kdk With filesize()
# 2022-02-23 0.27 kdk ShellCheck adaptions
# 2022-12-11 0.28 kdk With deleteLeadingAndTrailingSpaces()
# 2023-11-30 0.29 kdk Comments added how to use this file
# 2024-07-18 0.30 kdk deleteLeadingAndTrailingSpaces() optimized a little bit
# 2025-01-03 0.31 kdk Global Variables Section added to reduce warnings

# #########################################
#
# MIT license (MIT)
#
# Copyright 2025 - 2021 Karsten Köth
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
# Global Variables
#

LogFile=""
RunFile=""

MainLoopSleepFactor=10
MainLoopResponseTime="1s"

# #########################################
#
# Functions
#

# #########################################
# echod
# Shows debug messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echod()
{
  if [ "$ECHODEBUG" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echov
# Shows verbose messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echov()
{
  if [ "$ECHOVERBOSE" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echon
# Shows normal messages. Could be switched off with e.g. "-q" = "--quiet"
# Parameters:
# $1 : Function calling
# $2 : Content
function echon()
{
  if [ "$ECHONORMAL" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echow
# Shows warning messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echow()
{
  if [ "$ECHOWARNING" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echoe
# Shows error messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echoe()
{
  if [ "$ECHOERROR" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}


# #########################################
# fileSize()
# Parameter
#   1: file name
# Return
#   File size in Bytes
# Function first used inside AssetHub Usage Scripts (MIT License)
# Tested at:
# "17.7.0" = MAC OS X High Sierra 10.13.6
# SUSE Linux Enterprise Server 15 SP1
function fileSize()
{
    if [ -f "$1" ] ; then
        # Get file size
        # tSize=$(wc -c "$1" | cut -d " " -f 1 -) # Too unsecure, sometimes more " " before the first value.
        # tSize=$(ls -l "$1" | cut -d " " -f 5 -)  # Too unsecure, sometimes more " " between values.
        tSize=$(wc -c "$1" | awk '{print $1}')
        echo "$tSize"
    fi
}


# #########################################
# checkOrCreateFolder()
# Parameter
#   1: folder name
#   2: folder description
# Return
#   1: 1 = An error occured
# This function checks if a folder exists. If not, it creates the folder.
# Check return value e.g. with: if [ $? -eq 1 ] ; then echo "There was an error"; fi
function checkOrCreateFolder()
{
    if [ ! -d "$1" ] ; then        
        mkdir "$1"
        if [ -d "$1" ] ; then
            echo "[$PROG_NAME:DEBUG] $2 folder created."
        else
            echo "[$PROG_NAME:ERROR] $2 folder could not be created."
            return 1
        fi        
    fi        
}


# #########################################
# checkOrCreateFile()
# Parameter
#   1: file name
#   2: file description
# Return
#   1: 1 = An error occured
# This function checks if a file exists. If not, it creates the file.
# Check return value e.g. with: if [ $? -eq 1 ] ; then echo "There was an error"; fi
function checkOrCreateFile()
{
    if [ ! -f "$1" ] ; then        
        touch "$1"
        if [ -f "$1" ] ; then
            echo "[$PROG_NAME:DEBUG] $2 file created."
        else
            echo "[$PROG_NAME:ERROR] $2 file could not be created."
            return 1
        fi        
    fi        
}


# #########################################
# isNumber()
# Parameter
#   1: String to check
# Return Value
#   1: 0 = Is number
#      1 = Is not number
# Check, if the string contains only digits.
function isNumber()
{
case $1 in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
esac
}

# #########################################
# random()
# Parameter
#   1: Maximum Number
# Return
#   Random number between 1 and "Maximum Number"
# Generates a random number (positive integer) between 1 and maximum 32759
# See: https://stackoverflow.com/questions/8988824/generating-random-number-between-1-and-10-in-bash-shell-script/23093194
function random()
{
    while :; do ran=$RANDOM; ((ran < 32760)) && echo $(((ran%$1)+1)) && break; done
}

# #########################################
# deleteQuotationMark()
# Parameter
#    1: String to remove the quotation marks from
# Return
#    1: Input string without quotation marks
# All quotation marks will be removed.
function deleteQuotationMark()
{
    s=$(echo "$1" | sed -- "s/\"//g")
    echo "$s"
}

# #########################################
# deleteLeadingAndTrailingSpaces()
# Parameter
#    1: String to remove the chars from
# Return
#    1: Input string without the chars
# Leading and trailing spaces will be removed.
function deleteLeadingAndTrailingSpaces()
{
    # s=$(echo "$1" | sed "s/^ *//g" | sed "s/$ *//g")
    s=$(echo "$1" | sed -e "s/^ *//g" -e "s/$ *//g")
    echo "$s"
}

# #########################################
# updateLog()
# Parameter
# Write time stamp into log file.
function updateLog()
{
    touch "$LogFile"
}

# #########################################
# updateRun()
# Parameter
# Write time stamp into run file.
function updateRun()
{
    touch "$RunFile"
}

# #########################################
# delFile()
# Parameter
#   1: File name
# Deletes a file, if it exists.
function delFile()
{
    if [ -f "$1" ] ; then
        rm "$1"
    fi
}

# #########################################
# checkExit()
# Parameter
# Checks if the script should be terminated.
function checkExit()
{
    local counter=0
    while [ $counter -lt $MainLoopSleepFactor ] 
    do
        counter=$(expr $counter + 1)
        sleep "$MainLoopResponseTime"
        # If someone or something deletes the RunFile, the program should break the MainLoop:
        if [ ! -f "$RunFile" ] ; then counter=$MainLoopSleepFactor; fi
        updateLog
    done
}

# #########################################
# checkStart()
# Parameter
# Checks, if the shell script is running in another instance and exits if yes.
function checkStart()
{
  if [ -e "$RunFile" ]  ; then
    echo "[$PROG_NAME:ERROR] Maybe an older instance is running. If not: Delete '$RunFile' and start again. Exit."
    exit 
  fi
}
