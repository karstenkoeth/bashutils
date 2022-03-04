#!/bin/bash

# #########################################
#
# Overview
#
# This script looks for the specific values of a device:
# - Used disk Space
# - CPU Usage
# - Memory Usage
# - Last Update 

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version
# 2020-12-20 0.02 kdk With actDateTime
# 2021-01-29 0.03 kdk 2021 year ready, with PROG_DATE and Copyright in help, with showVersion()
# 2021-02-08 0.04 kdk License text enhanced.
# 2021-08-10 0.05 kdk Device Monitor started.
# 2021-09-13 0.06 kdk Doing some tests and write comments
# 2021-12-08 0.07 kdk Comments added
# 2022-01-31 0.08 kdk System check enhanced and getDiskSpace adapted to MAC OS X
# 2022-02-01 0.09 kdk Change from "==" to "="
# 2022-03-01 0.10 kdk Ubuntu tested
# 2022-03-04 0.11 kdk Last echo adapted
# 2022-03-04 0.12 kdk Description:	Ubuntu 20.04.3 LTS tested
# 2022-03-04 0.13 kdk Description: With ish

PROG_NAME="Device Monitor"
PROG_VERSION="0.13"
PROG_DATE="2022-03-04"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="devicemonitor.sh"

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
DISKSPACE="0%"
SYSTEM="unknown"
    # Allowed values:
    # - MACOSX
    # - WIN
    # - LINUX
    # - SUSE
SYSTEMDescription="" # Will be filled if possible
SYSTEMTested="0" # If we detect a system, the script was tested on, we switch to "1"
MACADDRESS="00:00:00:00:00:00"

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
# getSystem()
# Parameter
#    -
# Return Value
#    -
# Global Variable
#    SystemType - Change the global variable SYSTEM
function getSystem()
{
    # Check, if program is available:
    unamePresent=$(which uname)
    if [ -z "$unamePresent" ] ; then
        echo "[$PROG_NAME:ERROR] 'uname' not available. Exit"
        exit
    else
        sSYSTEM=$(uname -s) 
        # Detect System:
        #echo "$sSYSTEM" # ########################################### DEBUG
        if [ "$sSYSTEM" = "Darwin" ] ; then
            SYSTEM="MACOSX"
            # More specific: 
            # The variable $OSTYPE contains more precisely the system version, e.g. "darwin17"
            # Or use uname -r for e.g. "17.7.0" = MAC OS X High Sierra 10.13.6
            #                     e.g. "4.20.69-ish" = iPhone SE 14.5.1 with ish-App
            #                     e.g. "4.20.69-ish" = iPad Air 2 14.7.1 with ish-App
            # https://de.wikipedia.org/wiki/Darwin_(Betriebssystem)
            SYSTEMDescription=$(uname -r)
            SYSTEMTested="0"
            if [ ! -z "$SYSTEMDescription" ] ;  then
                if [ "$SYSTEMDescription" = "17.7.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "4.20.69-ish" ] ; then
                    SYSTEMTested="1"
                fi
                # ... Add more known and tested systems.
            fi
            # Be paranoid: If nothing found, be sure the string is clean:
            if [ "$SYSTEMTested" = "0" ] ; then
                SYSTEMDescription=""
            fi
        elif [ "$sSYSTEM" = "Linux" ] ; then
            SYSTEM="LINUX"
            # More specific: 
            #
            # The variable $OSTYPE contains more precisely the system version.
            # But at the tested systems it contains only "linux"
            #
            lsbPresent=$(which lsb_release)
            # Works:    lsb_release -d
            # Alias is: lsb-release -d
            # e.g. "Description:    openSUSE Leap 15.2"
            # e.g. "Description:	SUSE Linux Enterprise Server 15 SP1"    # Tested on AWS
            if [ ! -z "$lsbPresent" ] ; then
                # We could get more information:
                SYSTEMDescription=$(lsb_release -d)
                SYSTEMTested="0"
                if [ ! -z "$SYSTEMDescription" ] ; then
                    if [ "$SYSTEMDescription" = "Description:	SUSE Linux Enterprise Server 15 SP1" ] ; then 
                        # The Script collection was tested on this system:
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 18.04.6 LTS" ] ; then
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 20.04.3 LTS" ] ; then
                        SYSTEMTested="1"
                    fi
                    # ... Add more known and tested systems.
                fi
                # Be paranoid: If nothing found, be sure the string is clean:
                if [ "$SYSTEMTested" = "0" ] ; then
                    SYSTEMDescription=""
                fi
            fi
            #
            # Works also: cat /etc/os-release
            #
            # Maybe we have a Linux running on Windows with WSL:
            # uname -r   +   if the kernel version => 4.19, it's WSL Version 2
        else
            SYSTEM="Unknown"
        fi
    fi
}

# #########################################
# getDiskSpace()
# Parameter
#    -
# Return Value
#    -
# Get disk space from root file system - Change the global variable DISKSPACE
function getDiskSpace()
{
    if [ "$SYSTEM" = "LINUX" ] ; then
        # Runs on "Ubuntu 18.04.5":
        # Runs on "SUSE Linux Enterprise Server 15 SP1":
        # Runs on "openSUSE Leap 15.2":
        DISKSPACE=$(df -h / --output=pcent | tail -n 1 | xargs)
    elif [ "$SYSTEM" = "MACOSX" ] ; then
        # Example:
        # Filesystem     Size   Used  Avail Capacity iused               ifree %iused  Mounted on
        # /dev/disk1s1   500G   431G    58G    89% 2908579 9223372036851867228    0%   /
        #sStringZ=$(df -H / | tail -n 1 | cut -d "%" -f 1)
        #DISKSPACE=$(echo ${sStringZ: -3}"%")
        DISKSPACE=$(df -H / | tail -n 1 | xargs | cut -d " " -f 5)
    else
        echo "TODO"
    fi
}

# #########################################
# getMacAddress()
# Parameter
#    -
# Return Value
#    -
# Get MAC address from ... ethernet interface - Change the global variable MACADDRESS
function getMacAddress()
{
    # With 'ip addr show' we see all mac addresses and the corresponding ip addresses.
    # Works under: WSL - Linux - SuSE
    echo "TODO"
}

# #########################################
# showInfo()
# Parameter
#    -
# Return Value
#    -
# Shows the collection information
function showInfo()
{
    echo "[$PROG_NAME:STATUS] System Type      : $SYSTEM"
    if [ "$SYSTEMTested" = "1" ] ; then
    echo "[$PROG_NAME:STATUS] System Version   : $SYSTEMDescription"
    fi
    echo "[$PROG_NAME:STATUS] Usage Disk Space : $DISKSPACE" 
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
    fi
fi

# Check, on which system we are running:
getSystem

# Do something ...
getDiskSpace
#getMacAddress

# Show Info:
showInfo

# End:
echo "[$PROG_NAME:STATUS] Done."
