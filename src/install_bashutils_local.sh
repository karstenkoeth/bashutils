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
# 2021-03-15 0.08 kdk TODO comment added
# 2021-04-11 0.09 kdk PROG_CLASS added
# 2021-12-08 0.10 kdk Comments added
# 2022-02-07 0.11 kdk TODO added
# 2022-02-23 0.12 kdk ShellCheck optimized
# 2022-02-23 0.13 kdk DateTime adapted to standard format for file names
# 2022-02-28 0.14 kdk Comments added
# 2022-03-01 0.15 kdk Comments added and sudo depends on user != root
# 2022-03-01 0.16 kdk Package Manager check added

PROG_NAME="Bash Utils Installer (local)"
PROG_VERSION="0.16"
PROG_DATE="2022-03-01"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="install_bashutils_local.sh"
PROG_LIBRARYNAME="bashutils_common_functions.bash"

# #########################################
#
# TODO
#
# https://trello.com/c/5bsK792K/409-bashutils-ish

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


# #########################################
#
# Variables
#

#actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
actDateTime=$(date "+%Y-%m-%d.%H_%M_%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="1"
ECHOVERBOSE="1"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

# Script specific Apps:
appSudo="sudo"

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

echo "[$PROG_NAME:STATUS] Starting installer ..."

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ "$1" = "-V" ] ; then
        showVersion ; exit;
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

# Most scripts inside bashutils need this directory:
TmpDir="$HOME/tmp/"
mkdir -p -v "$TmpDir"
if [ ! -d "$TmpDir" ] ; then
    echo "[$PROG_NAME:ERROR] Can't create temporary directoy. Exit."
    exit
fi

# On ubuntu 18.04 in docker: Here we are acting as root and therefore "sudo" is unknown.
#   --> First, we have to look, if we are running as "root" or not:
appUser=$(whoami)
if [ "$appUser" = "root" ] ; then
    appSudo=""
fi

# TODO
#
#
# Here first to check if "sudo" is available:
#tmp=$(which sudo)
#if [ -z "$tmp" ] ; then
#   appSudo=""
#else
#   appSudo="sudo"
#fi

# On SUSE, the program cnf could answer in which software package a program is included.
# On Ubuntu, the website https://packages.ubuntu.com/ could answer in which software package a program is included.

# Before update the system: detect the system we are running on:
# TODO: Use function:
# TODO: If Linux, which linux?
# See also: bashutils - devicemonitor.sh - getSystem()
# to detect, we need some programs - have to install:
#
# SuSE:
# Das Programm 'lsb_release' kann im folgenden Paket gefunden werden:
#  * lsb-release [ Pfad: /usr/bin/lsb_release, Repository: zypp (Basesystem_Module_x86_64:SLE-Module-Basesystem15-SP1-Pool) ]
# Zum Installieren versuchen Sie:
#    sudo zypper install lsb-release
#
# Ubuntu
# Das Programm 'lsb-release' kann im folgenden Paket gefunden werden:
#  * lsb-release 
# Zum Installieren versuchen Sie:
#    sudo apt-get -y install lsb-release

# No idea on which system we are - but we could check which package manager we could use:
aptgetPresent=$(which apt-get)
zypperPresent=$(which zypper)
brewPresent=$(which brew)

# Allways good idea to update the system, here on Ubuntu:
if [ -x "$aptgetPresent" ] ; then
    $appSudo apt-get -y update 
fi
# Same on openSUSE:
if [ -x "$zypperPresent" ] ; then
    $appSudo zypper --non-interactive refresh
fi
# Same on MAC OS X (here, sudo brew is no more supported):
if [ -x "$brewPresent" ] ; then
    $appSudo brew update
    $appSudo brew upgrade
fi

# 'lsb-release' is needed to detect on which Linux version we are running.
lsbreleasePresent=$(which lsb-release)
if [ -z "$lsbreleasePresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        # We could use apt-get:
        $appSudo apt-get -y install lsb-release
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install lsb-release  # NOT TESTED
    fi
fi
# Check, if we are successful:
lsbreleasePresent=$(which lsb-release)
if [ -z "$lsbreleasePresent" ] ; then
    # Sometimes a little bit different spelling:
    lsbreleasePresent=$(which lsb_release)
fi
if [ -z "$lsbreleasePresent" ] && [ -z "$brewPresent" ] ; then
    echo "[$PROG_NAME:ERROR] Can't find 'lsb-release' or 'brew'. Exit."
    exit
fi

# 'file' is not standard --> Install it:
filePresent=$(which file)
if [ -z "$filePresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        # We could use apt-get:
        $appSudo apt-get -y install file
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install file  # NOT TESTED
    fi
fi


# iPad-von-Kasa:~# rki.sh # Diese Fehler liefert das Programm:
# /root/bin/rki.sh: line 101: curl: command not found
# /root/bin/rki.sh: line 103: jq: command not found

# Minimal "Bash rc" erzeugen, falls nicht vorhanden.
#
# ___
# .bashrc
# export PATH=$PATH:/root/bin


# Make sure all necessary tools are present:
uuidgenPresent=$(which uuidgen)
if [ -z "$uuidgenPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install uuid-runtime
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install uuid  # NOT TESTED
    fi
fi

# TODO
# Old-Style Text Editor:
# sudo apt-get -y install joe

# TODO
# Maybe we want to use AWS CLI:
#sudo apt-get -y install awscli

# At the moment not needed - but a good function - ?
Uuid=$(uuidgen)
TmpFile="$TmpDir$actDateTime.$Uuid.tmp"
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

# TODO
# Maybe we want to test internet connection:
# ping -c 1 -w 1 -W 1 8.8.8.8
# ping -c 1 8.8.8.8 | head -n 2 | tail -n 1 | cut -f 7 -d " "

# TODO
# Maybe we want to test speed to internet:
# sudo apt-get -y install speedtest-cli
# Runs on EC2 with Ubuntu 18.04.5 LTS
# Not available on OpenSUSE Linux Enterprise Server 15 SP1
# --> ubuntu is better maintained as SUSE
# Runs on MAC OS X:
# brew install speedtest-cli

# TODO
# Maybe we want to know other MAC addresses in the network:
# sudo apt-get -y install arping
# sudo apt-get -y install nmap

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
