#!/bin/bash

# #########################################
#
# Overview
#
# Check out with:
# git clone https://github.com/karstenkoeth/bashutils.git
#
# This script installs the bashutils in the user directory.
#
# Tested at:
# - MAC OS X 10.13.6
# - raspi

# #########################################
#
# Versions
#
# 2020-12-17 0.03 kdk First Version with version history
# 2020-12-20 0.04 kdk With getFunctionsFile
# 2021-01-14 0.05 kdk apt-get added
# 2021-02-04 0.06 kdk apt-get for AWS CLI
# 2021-02-25 0.07 kdk TODO comment added

PROG_NAME="Bash Utils Installer (local)"
PROG_VERSION="0.06"
PROG_SCRIPTNAME="install_bashutils_local.sh"
PROG_LIBRARYNAME="bashutils_common_functions.bash"

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

actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="1"
ECHOVERBOSE="1"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

# #########################################
#
# Functions
#

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
    echo "Copy all script files from the source directoy"
    echo "(typicalle created with git clone https://github.com/karstenkoeth/bashutils.git)"
    echo "to the bin-directory of the user."
}


# #########################################
#
# Main
#

echo "[$PROG_NAME:STATUS] Starting installer ..."

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ "$1" = "-V" ] ; then
        echo "[$PROG_NAME:STATUS] Version $PROG_VERSION" ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

# Check if we are in the source directory:
SourceDir=$(dirname "$0")
InstallScript="$SourceDir/$PROG_SCRIPTNAME"
if [ ! -f "$InstallScript" ] ; then
    echo "[$PROG_NAME:ERROR] Source directory not found. Exit."
    exit
fi

# Prepare destination directory:
DestDir="$HOME/bin/"
mkdir -p -v "$DestDir"
if [ ! -d "$DestDir" ] ; then
    echo "[$PROG_NAME:ERROR] Destination directoy not found. Exit."
    exit
fi

TmpDir="$HOME/tmp/"
mkdir -p -v "$TmpDir"
if [ ! -d "$TmpDir" ] ; then
    echo "[$PROG_NAME:ERROR] Can't create temporary directoy. Exit."
    exit
fi

# TODO
# Here first to check if "sudo" is available:
#tmp=$(which sudo)
#if [ -z "$tmp" ] ; then
#   appSudo=""
#else
#   appSudo="sudo"
#fi

# Allways good idea to update the system:
sudo apt-get -y update 
# TODO
# Same on openSUSE:
# sudo zypper --non-interactive refresh

# Make sure all necessary tools are present:
uuidgenPresent=$(which uuidgen)
if [ -z "$uuidgenPresent" ] ; then
    sudo apt-get -y install uuid-runtime
fi

# TODO
# Old-Style Text Editor:
# sudo apt-get -y install joe

# TODO
# Maybe we want to use AWS CLI:
#sudo apt-get -y install awscli

# At the moment not needed - but a good function - ?
Uuid=$(uuidgen)
TmpFile="$TmpDir$actDateTime_$Uuid.tmp"
touch "$TmpFile"
if [ ! -f "$TmpFile" ] ; then
    echo "[$PROG_NAME:ERROR] Can't create temporary file. Exit."
    exit
fi

# TODO
# Maybe we want to use MQTT:
# The Broker:
#sudo apt-get -y install mosquitto
# The Command Line Clients:
#sudo apt-get -y install mosquitto-clients
#
# Under openSUSE:
#sudo zypper --non-interactive install mosquitto-clients
#
# Now, it would be cool to write a standard config file:
# Only do it, if no one is present!
#confMosquitto="~/.mosquitto.conf"
#echo "listener 1883" >> "$confMosquitto"
#echo "allow_anonymous true" >> "$confMosquitto"

# At the moment not needed - but a good function:
# getFunctionsFile()
FunctionLibrary="$SourceDir/$PROG_LIBRARYNAME"
if [ ! -f "$FunctionLibrary" ] ; then
    echo "[$PROG_NAME:WARNING] Function Library not found. Working with reduced functionality."
else
    source "$FunctionLibrary"
    echod "Main" "Function Library found."
fi

# Normally, it is save to go with a file to support file names with spaces inside the name.
# But here, we only care about shell scripts - these we write without spaces in th name.
# ls -1 $SourceDir/*.sh > "$TmpFile"
lines=$(ls -1 $SourceDir/*.sh)

for line in $lines
do
    pureLine=$(basename "$line")
    case $pureLine in 
        "install_bashutils_local.sh"|"bash-script-template.sh")
            echo "[$PROG_NAME:STATUS] Exclude of copy '$pureLine' "
        ;;
        *)
            #echo "[$PROG_NAME:STATUS] Line:        Copy '$line' "
            # TODO Think about "Copy": It's ok to overwrite all files?
            cp "$line" "$DestDir"
            chmod u+x "$DestDir$pureLine"    
        ;;
    esac
done

# Cleaning up:
if [ -f "$TmpFile" ] ; then
    rm "$TmpFile"
fi

echo "[$PROG_NAME:STATUS] Done."
