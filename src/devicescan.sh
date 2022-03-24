#!/bin/bash

# #########################################
#
# Overview
#
# This script scans ip addresses in the local network

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version
# 2020-12-20 0.02 kdk With actDateTime
# 2021-01-29 0.03 kdk 2021 year ready, with PROG_DATE and Copyright in help, with showVersion()
# 2021-02-08 0.04 kdk License text enhanced.
# 2021-12-08 0.01 kdk First version of devicescan.sh
# 2022-03-23 0.02 kdk With scanDevice()
# 2022-03-24 0.03 kdk With more comments

PROG_NAME="Device Scan"
PROG_VERSION="0.03"
PROG_DATE="2022-03-24"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="devicescan.sh"

# #########################################
#
# TODOs
#

# #########################################
#
# Uses
#
# tr
# nmap
# arp
# ip
# sed
# date
# mkdir
# touch
# which
# sudo
# cat
# cut
# grep
# echo
# mac_converter.sh

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2022 - 2021 Karsten Köth
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
actDateTime=$(date "+%Y-%m-%d_%H:%M:%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

TmpDir="$HOME/tmp/"
TmpFile="devicescan_nmap_$actDateTime.txt"
ScanFile="devicescan_devices_$actDateTime.txt"
MacFile="devicescan_mac_$actDateTime.txt"

# #########################################
#
# Functions
#

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
# checkEnvironment()
# Parameter
#    -
# Return Value
#    -
# Check for necessary programs and folders.
function checkEnvironment()
{
    checkOrCreateFolder "$TmpDir" "Temporary"
    if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Temporary folder '$TmpDir' not usable. Exit"; exit; fi

    checkOrCreateFile "$TmpDir$TmpFile" "Temporary"
    if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Temporary file '$TmpDir$TmpFile' not usable. Exit"; exit; fi

    nmapProgram=$(which nmap)
    if [ -z "$nmapProgram" ] ; then echo "[$PROG_NAME:ERROR] Necessary program 'nmap' not found. Exit"; exit; fi

}

# #########################################
# scanDevice()
# Parameter
#    1: ip address to scan, e.g. "192.168.0.2"
# Return Value
#    -
# The result will be shown on stdout
function scanDevice()
{
    sudo nmap -R -T Normal "$1" 
}

# #########################################
# getHostname()
# Parameter
#    MAC Address (in upper Case)
# Return Value
#    -
# The result will be written to stdout
function getHostname()
{
    # TODO Name abstrahieren
    cat ~/Documents/Infrastruktur/Netzwerk.txt | grep ";" | grep "$1" | cut -d ";" -f 2
}

# #########################################
# listMacAddresses()
# Parameter
#    -
# Return Value
#    -
# The scanNetwork() must be called first!
# The result will be written down in the tmp file
function listMacAddresses()
{
    # #####################################
    # ip - Version

    # ip -4 neigh : Shows the ip and mac addresses in one line, e.g.:
    # 192.168.0.176 dev eth0 lladdr 68:5b:35:be:43:49 REACHABLE
    # 192.168.0.220 dev eth0  FAILED
    # Show only lines with MAC Addresses and show with uppercase letters:
    # ip -4 neigh | grep ":" | tr "[:lower:]" "[:upper:]"
    # IP  Address: cut -d " " -f 1
    # MAC Address: cut -d " " -f 5   <-- Could be non present, check for "contains 5 : ", see above

    # #####################################
    # arp - Version

    # If first the network was scanned, the arp cache is filled.
    arp -a > "$TmpDir$MacFile.tmp"
    # Filter the output to have only a list of MAC addresses:
    cat "$TmpDir$MacFile.tmp" | cut -f 4 -d " " | grep ":" > "$TmpDir$MacFile.mac"
    # Make clean:
    # Enhance at the beginning from 1 char to 2 chars:   sed "s/^\(.\):/0\1:/g"
    # Enhance in the middle from 1 char to 2 chars:      sed "s/:\(.\):/:0\1:/g"
    # Enhance at the end from 1 char to 2 chars:         sed "s/:\(.\)$/:0\1/g"
    cat "$TmpDir$MacFile.mac" | sed "s/^\(.\):/0\1:/g" | sed "s/:\(.\)$/:0\1/g" | sed "s/:\(.\):/:0\1:/g" | sed "s/:\(.\):/:0\1:/g" | mac_converter.sh -L -x > "$TmpDir$MacFile"
    
    # TODO: Remove "#"
    # Clean up:
    #rm "$TmpDir$MacFile.tmp"
    #rm "$TmpDir$MacFile.mac"
}

# #########################################
# scanNetwork()
# Parameter
#    1: network part to scan, e.g. "192.168.0.*"
# Return Value
#    -
# The result will be written down in the tmp file
function scanNetwork()
{
    # Lists all devices (which could be pinged) into file:
    nmap -sn "$1" -oG "$TmpDir$TmpFile"
    # Typical line in file: 
    # Host: 192.168.0.1 (kabelbox.local)	Status: Up
    # Extract ip addresses into next file:
    cat "$TmpDir$TmpFile" | grep "Host" | cut -f 2 -d " " > "$TmpDir$ScanFile"
    # Scan each device exactly
    # for ...
    echo "[$PROG_NAME:DEBUG] TODO"
}

# #########################################


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
    if [ -f "$1" ] ; then
        echo "[$PROG_NAME:STATUS] Input file exists."
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

echo "[$PROG_NAME:STATUS] Check folders ..."
checkEnvironment

echo "[$PROG_NAME:STATUS] Scan network ..."
scanNetwork "192.168.0.*" # TODO: Automatically detect which network we should scan.

echo "[$PROG_NAME:STATUS] Get MAC addresses ..."
listMacAddresses

echo "[$PROG_NAME] Done."
