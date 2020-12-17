#!/bin/bash

# #########################################
#
# Versions
#
# 2020-12-17 0.03 kdk First Version with version history

PROG_NAME="Bash Utils Installer (local)"
PROG_VERSION="0.03"

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
InstallScript="$SourceDir/install_bashutils_local.sh"
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

Uuid=$(uuidgen)
TmpFile="$TmpDir$Uuid.tmp"
touch "$TmpFile"
if [ ! -f "$TmpFile" ] ; then
    echo "[$PROG_NAME:ERROR] Can't create temporary file. Exit."
    exit
fi

ls -1 $SourceDir/*.sh > "$TmpFile"

# TODO Hier weiter
# For i=1 to EOF do if not install script
# cp -i "$SourceDir/*.sh" "$DestDir"
# chmod u+x 

echo "[$PROG_NAME:STATUS] Done."
