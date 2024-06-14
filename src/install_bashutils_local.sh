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
# - MacBook - MAC OS X 10.13.6
# - MacBook - MAC OS X 12.6
# - MacBook - MAC OS X 13.3.1
# - raspi
# - EC2 - Ubuntu
# - WSL - Ubuntu
# - Lenovo - Ubuntu
# - iPhone - ish

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
# 2022-03-01 0.17 kdk with snapd package manager
# 2022-03-04 0.18 kdk With ish
# 2022-03-05 0.19 kdk Create .bashrc 
# 2022-03-24 0.20 kdk Comments added
# 2022-04-01 0.21 kdk Export Path with $HOME/bin
# 2022-04-08 0.22 kdk Comments added
# 2022-05-02 0.23 kdk TODO added
# 2022-05-20 0.24 kdk brew without sudo
# 2022-06-27 0.25 kdk Comments added
# 2022-09-19 0.26 kdk rsync comments
# 2022-10-12 0.27 kdk git added
# 2022-10-21 0.28 kdk curl, jq, packageManagerUpdate() added
# 2022-10-24 0.29 kdk git in brew
# 2022-10-24 0.30 kdk jq in brew
# 2022-10-31 0.31 kdk joe in brew
# 2022-11-01 0.32 kdk Comments added
# 2022-11-10 0.33 kdk croc added
# 2022-11-10 0.34 kdk nmap with brew added
# 2022-11-11 0.35 kdk oidc-agent added
# 2022-11-16 0.36 kdk With input from cli.sh
# 2022-11-25 0.37 kdk Comments added, socat added
# 2022-12-05 0.38 kdk Comments added
# 2023-01-14 0.39 kdk SHORT added
# 2023-01-14 0.40 kdk Missing which added by rsync
# 2023-01-25 0.41 kdk gnuplot added for devicescan.sh
# 2023-02-03 0.42 kdk More adaption to OpenSuSe
# 2023-02-03 0.43 kdk Much more " 2> /dev/zero" added after "which"
# 2023-02-07 0.44 kdk TODOs added
# 2023-03-10 0.45 kdk TODOs added
# 2023-04-11 0.46 kdk TODOs added
# 2023-04-12 0.47 kdk Sections introduced and caddy included
# 2023-04-20 0.48 kdk Comments added for caddy
# 2023-05-04 0.49 kdk Bug fixing for caddy install section on MAC OS X
# 2023-06-27 0.50 kdk Comments added
# 2023-07-06 0.51 kdk Comments added
# 2023-11-17 0.52 kdk Comments added
# 2023-11-24 0.53 kdk wget for MAC OS X
# 2023-11-28 0.54 kdk Test
# 2023-11-28 0.55 kdk Auto detect install location
# 2023-11-28 0.56 kdk Go on with auto update
# 2023-11-30 0.57 kdk Added: cleanUp(), Deleted the including of $PROG_LIBRARYNAME
# 2024-01-09 0.58 kdk Links added
# 2024-01-21 0.59 kdk Bash Prompt added
# 2024-01-24 0.60 kdk Bash alias added
# 2024-01-26 0.61 kdk apt-get improved for Cleaning and OS Update
# 2024-02-08 0.62 kdk cryptsetup added, tested under Ubuntu 22.04.3 LTS with Kernel 5.15.133.1-microsoft-standard-WSL2
# 2024-02-19 0.63 kdk gnuplot comment
# 2024-03-01 0.64 kdk Comments added
# 2024-03-21 0.65 kdk mDNS comments added
# 2024-03-25 0.66 kdk lesspipe
# 2024-06-14 0.67 kdk Comments changed

PROG_NAME="Bash Utils Installer (local)"
PROG_VERSION="0.67"
PROG_DATE="2024-06-14"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="install_bashutils_local.sh"
PROG_LIBRARYNAME="bashutils_common_functions.bash"

# #########################################
#
# TODO
#
# https://trello.com/c/5bsK792K/409-bashutils-ish
#
# devicemonitor.sh - getCpuUsage() : Test on Ubuntu
# devicescan.sh - getOwnMacAddress() : For Ubuntu maybe change to 'nmcli' instead 'ip addr show' 

# #########################################
#
# Updates
#
# Use cron, anacron or systemd/system to trigger daily update checks.
# /etc/systemd/system
# See:
# https://wiki.ubuntuusers.de/Cron/
# https://linux.die.net/man/1/crontab
# https://wiki.ubuntuusers.de/systemd/Timer_Units/
#
# One time jobs could be defined as user with e.g.:
#  >: systemd-run --user --on-calendar="2023-11-28 15:50:00" --unit="BashUtils" --description="BashUtils Updater" touch ~/tmp/calendarTouchMe

# #########################################
#
# printf
#
# See:
# https://phoenixnap.com/kb/bash-printf
#
# Store string in a variable "$bla": >: printf -v bla "hallo"
#
# Localisation
#
# See: 
# https://www.gnu.org/software/bash/manual/bash.html#Locale-Translation
# https://www.baeldung.com/linux/locale-environment-variables
# https://man7.org/linux/man-pages/man1/locale.1.html
#
# Default: LANG=C.UTF-8
# >: env LC_NUMERIC=en_US.UTF8 printf '%f\n' 1233.14
# 1233.140000
# >: env LC_NUMERIC=de_DE.UTF8 printf '%f\n' 1233.14
# 1233,140000
#
# Shows the different variables:
#   >: locale 
# Shows the different constants for the possible languages on that specific system instance:
#   >: locale -a
# Shows the value of the keyword "decimal_point":
#   >: locale -k decimal_point
#   e.g.: decimal_point=","

# #########################################
#
# The bashutils scripts are using the following programs and functions:
#
# devicemonitor:
# - awk
# - cat             *
# - cut             *
# - date            *
# - df
# - echo
# - grep
# - lsb_release
# - mkdir
# - printf
# - rm
# - sed             *
# - sleep
# - tail
# - top
# - touch
# - uname
# - which
# - xargs
#
# devicescan:
#
# See upper part of file devicescan.sh
#
# http-echo:
# - cat             *
# - cut             *
# - date            *
# - grep
# - kill
# - mkdir
# - ps
# - sed             *
# - socat           *
# - uuidgen         *
#
# http-text:
# - cat             *
# - cut             *
# - date            *
# - grep
# - mkdir           *
# - sed             *
#
# git-commit:
# date              *
# git               *
#
# *These programs are checked inside this script.
#
# Usage-Scripts:
# gnuplot

# #########################################
#
# MIT license (MIT)
#
# Copyright 2024 - 2020 Karsten Köth
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

product="bashutils"

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

DEPENDENCIES="0"
SHORT="0"
RASPUPGRADE=""
SYSTEM="Unknown"

SourceDir="-"
DestDir="-"
TmpDir="-"


# Standard Folders and Files

MainFolder="_"              # Set in adjustVariables()
DownloadsFolder="_"         # Set in adjustVariables()
ControlFolder="_"           # Set in adjustVariables()
ProcessFolder="_"           # Set in adjustVariables()

RunFile="_"
LogFile="_"

ConfigFile="_"              # Set in adjustVariables()

# Script specific Apps:
appSudo="sudo"

# #########################################
#
# Functions
#


# #########################################
# packageManagerUpdate()
# Parameter
#    -
# Return Value
#    -
# Updates all software packages of the supported package managers.
# This can take a long time. Therefore this function should not be use every time.
function packageManagerUpdate()
{
    # Here on Ubuntu:
    if [ -x "$aptgetPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Update system package manager ..."
        # Update the list of packages
        $appSudo apt-get -y update 
        # Allways a good idea to update all installed packages. This is typically 
        # called 'upgrade'.
        $appSudo apt-get -y upgrade 
        # Update all installed packages AND remove unneccessary things:
        $appSudo apt -y full-upgrade
    fi

    # Same on openSUSE:
    if [ -x "$zypperPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Update system package manager ..."
        $appSudo zypper --non-interactive refresh
    fi

    # Same on MAC OS X (here, sudo brew is no more supported):
    if [ -x "$brewPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Update brew installer part ..."
        # 2022: brew should no longer be used as root. Therefore do not use sudo:
        appSudo=""
        $appSudo brew update
        $appSudo brew upgrade
    fi

    # Same on iPads inside the 'ish' program, an Alpine Linux Version.
    # See help e.g. at: https://wiki.alpinelinux.org/wiki/Package_management
    if [ -x "$apkPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Update system package manager ..."
        $appSudo apk update
        $appSudo apk upgrade
    fi
}

# #########################################
# packageManagerCleaning()
# Parameter
#    -
# Return Value
#    -
# Delete the no more needed packages.
# This can take a long time. Therefore this function should not be use every time.
function packageManagerCleaning()
{
    if [ -x "$aptPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Cleaning system package manager databases ..."
        $appSudo apt -y autoremove
        $appSudo apt-get -y autoclean
    fi
    # Here on Ubuntu:
    if [ -x "$aptgetPresent" ] ; then
        echo "[$PROG_NAME:STATUS] Cleaning system package manager databases ..."
        $appSudo apt-get -y autoremove
        $appSudo apt-get -y autoclean
    fi
}

# #########################################
# osUpgrade()
# Parameter
#    UpgradeType
# Return Value
#    -
# Updates the OS version e.g. from Ubuntu 18 to Ubuntu 20.
# This can take a long time. Therefore this function should not be use every time.
# UpgradeType = "u": Update Ubuntu
#
# Update von OS Raspian stretch to buster.
# See: https://devdrik.de/upgrade-stretch-auf-buster/
# UpgradeType = "s2b": stretch --> buster
# UpgradeType = "b2b": buster --> bullseye
# UpgradeType = "b2o": bullseye --> bookworm
function osUpgrade()
{
    # TODO: Not yet finalized: How to care about the save reboot process?

    # Under Ubuntu:
    $appSudo apt -y autoremove
    $appSudo apt -y update
    $appSudo apt -y upgrade
    $appSudo apt-get -y dist-upgrade
    # Different Raspberry OS Upgrades:
    if [ $# -gt 0 ] ; then
        # Change apt sources:
        if [ "$1" = "s2b" ] ; then
            $appSudo sed -i 's/stretch/buster/g' /etc/apt/sources.list    
            $appSudo sed -i 's/stretch/buster/g' /etc/apt/sources.list.d/raspi.list
        elif [ "$1" = "b2b" ] ; then
            $appSudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list    
            $appSudo sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/raspi.list
        elif [ "$1" = "b2o" ] ; then
            $appSudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list    
            $appSudo sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/raspi.list
        fi
    fi
    # OS Change:
    $appSudo apt-get -y update
    $appSudo apt-get -y full-upgrade
    # Check, if all other programs are clean shut down!
    if [ $# -gt 0 ] ; then
        echo "[$PROG_NAME:osUpgrade:STATUS] Please do a '$appSudo reboot'"
    fi
    # After reboot:
    #$appSudo do-release-upgrade  # <-- For Ubuntu, not for Raspbian
    # Clean up:
    #$appSudo apt-get -y autoremove
    #$appSudo apt-get -y autoclean
    
    # Not yet done because of some warnings...

    # Under Alpine Linux
    #$appSudo apt -y autoremove
}

# #########################################
# getSystem()
# Parameter
#    -
# Return Value
#    -
# Identifies the system type and changes the global variables: SYSTEM
# This function is a light version of getSystem() in devicemonitor.sh
function getSystem()
{
    # Check, if program is available:
    local unamePresent=$(which uname 2> /dev/zero)
    if [ -z "$unamePresent" ] ; then
        echo "[$PROG_NAME:getSystem:WARNING] 'uname' not available."
        SYSTEM="Unknown"
    else
        local sSYSTEM=$(uname -s) 
        # Detect System:
        if [ "$sSYSTEM" = "Darwin" ] ; then
            SYSTEM="MACOSX"
        elif [ "$sSYSTEM" = "Linux" ] ; then
            SYSTEM="LINUX"
        else
            SYSTEM="Unknown"
        fi
    fi
}

# #########################################
# adjustVariables()
# Parameter
# Sets the global variables 
function adjustVariables()
{
    # Linux like we should install e.g. under /opt/ or /usr/local/ - but we complete act inside home directory:
    MainFolder="$HOME/$product/"

    DownloadsFolder="$MainFolder""_Downloads/"

    ControlFolder="$MainFolder""_Control/"
        RunFile="$ControlFolder""RUNNING"
        LogFile="$ControlFolder""LOG"

    ProcessFolder="$MainFolder""_Process/"

    ConfigFile="$HOME/.$product.ini"
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
    checkOrCreateFile "$ConfigFile" "Configuration"
    if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Configuration file '$ConfigFile' not usable. Exit"; exit; fi

    checkOrCreateFolder "$MainFolder" "Main Program"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create main folder. Exit"; exit; fi
    checkOrCreateFolder "$DownloadsFolder" "Downloads"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create downloads folder. Exit"; exit; fi
    checkOrCreateFolder "$ControlFolder" "Control"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create control folder. Exit"; exit; fi
    checkOrCreateFolder "$ProcessFolder" "Process"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create process folder. Exit"; exit; fi
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
# checkOrCreateFolder()
# Parameter
#   1: folder name
#   2: folder description
# Return
#    0 = All ok
#    1 = An error occured
# This function checks if a folder exists. If not, it creates the folder.
# Check return value e.g. with: if [ $? -eq 1 ] ; then echo "There was an error"; fi
function checkOrCreateFolder()
{
    if [ ! -d "$1" ] ; then        
        mkdir "$1"
        if [ -d "$1" ] ; then
            echo "[$PROG_NAME:DEBUG] $2 folder created."
            return 0
        else
            echo "[$PROG_NAME:ERROR] $2 folder could not be created."
            return 1
        fi        
    fi  
    return 0      
}

# #########################################
# copyFiles()
# Parameter
#    -
# Return Value
#    -
# Copy all files of this all temporary files.
function copyFiles()
{
    # Normally, it is save to go with a file to support file names with spaces inside the name.
    # But here, we only care about shell scripts - these we write without spaces in the name.
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
}

# #########################################
# cleanUp()
# Parameter
#    -
# Return Value
#    -
# Delete all temporary files.
function cleanUp()
{
    if [ -f "$TmpFile" ] ; then
        rm "$TmpFile"
    fi
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
    echo "    -d     : Do not care about the dependencies"
    echo "    -s     : Do not update the packages descriptions and the package manager"
    echo "    -s2b   : Upgrade Raspberry OS from stretch to buster"
    echo "    -b2b   : Upgrade Raspberry OS from buster to bullseye"
    echo "    -b2o   : Upgrade Raspberry OS from bullseye to bookworm"
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
    if [ "$1" = "-d" ] ; then
        DEPENDENCIES="1"
    elif [ "$1" = "-s" ] ; then
        SHORT="1"
    elif [ "$1" = "-s2b" ] ; then
        RASPUPGRADE="s2b"
    elif [ "$1" = "-b2b" ] ; then
        RASPUPGRADE="b2b"
    elif [ "$1" = "-b2o" ] ; then
        RASPUPGRADE="b2o"
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

# Create our own environment:
adjustVariables
checkEnvironment

# Check if we are in the source directory:
SourceDir=$(dirname "$0")
InstallScript="$SourceDir/$PROG_SCRIPTNAME"
TestAnotherFile="$SourceDir/bash-script-template.sh"
if [ ! -f "$InstallScript" ] || [ ! -f "$TestAnotherFile" ] ; then
    # We are not in our download directory. Maybe we have to give up or we are able to use the standard way.
    # There are as minimum 2 different possible directories:
    #  1: For manual update any directory created with: git clone https://github.com/karstenkoeth/bashutils.git
    #  2: The standard directory created in adjustVariables()
    # We therefore check if we find the standard directory:
    if [ -d "$DownloadsFolder" ] ; then
        # Is git installed?
        gitPresent=$(which git 2> /dev/zero)
        if [ ! -z "$gitPresent" ] ; then
            cd "$DownloadsFolder"
            # We are in the correct download directory to clone the git repo.
            # Maybe it is not the first time for git in this directory - therefore we have to run git pull in bashutils.
            if [ ! -d "$product" ] ; then
                # First time for git here.
                git clone https://github.com/karstenkoeth/bashutils.git
            else
                # It is still cloned. We only need to pull new content:
                # We also could test more detailed, e.g. if "README.md" is present...
                cd "$product"
                git pull
                cd ..
            fi
        else
            # We have no idea where to find the files and we can't download them. --> We give up.
            echo "[$PROG_NAME:ERROR] Source directory not found and 'git' program not found. Exit."
            exit
        fi
        # We are now in the correct directory AND should have all files here.
        # 'git' should have created our directory:
        if [ -d "$product" ] && [ -d "$product/src" ] ; then
            cd "$product/src"
            SourceDir=$(pwd)
            # Now, we should be in the correct directoy. Test again:
            InstallScript="$SourceDir/$PROG_SCRIPTNAME"
            TestAnotherFile="$SourceDir/bash-script-template.sh"
            if [ ! -f "$InstallScript" ] || [ ! -f "$TestAnotherFile" ] ; then
                echo "[$PROG_NAME:ERROR] Source directory not found. Exit."
                exit
            fi
        else
            echo "[$PROG_NAME:ERROR] Download not successful. Exit."
            exit
        fi
    else
        echo "[$PROG_NAME:ERROR] Source and download directory not found. Exit."
        exit
    fi
fi

# Prepare destination directory:
DestDir="$HOME/bin/"
checkOrCreateFolder "$DestDir" "Binaries"

# Most scripts inside bashutils need this directory:
TmpDir="$HOME/tmp/"
checkOrCreateFolder "$TmpDir" "Temporary"

# Some scripts need to store secrets:
checkOrCreateFolder "$HOME/.ssh" "Secure Shell"
checkOrCreateFolder "$HOME/.oidc-agent" "OIDC Agent"

# Main function of this script:
copyFiles

# On ubuntu 18.04 in docker: Here we are acting as root and therefore "sudo" is unknown.
#   --> First, we have to look, if we are running as "root" or not:
appUser=$(whoami)
if [ "$appUser" = "root" ] ; then
    appSudo=""
fi

# TODO
#
#
# Here first to check if "sudo" is available:  - Why? Have had problems?
#tmp=$(which sudo)
#if [ -z "$tmp" ] ; then
#   appSudo=""
#else
#   appSudo="sudo"
#fi

# On SUSE, the program 'cnf' could answer in which software package a program is included.
# On Ubuntu, the website https://packages.ubuntu.com/ could answer in which software package a program is included.
#            Or use the program 'apt show' to show package details
# On Alpine Linux, the program 'apk search -v --description' could answer in which software package a program is included.
# On MAC OS X, the program 'brew info' could answer in which software package a program is included.
#              Or a look at: https://brew.sh

# Before update the system: detect the system we are running on:
# TODO: If Linux, which linux?
# See also: bashutils - devicemonitor.sh - getSystem()
getSystem

# To detect the system version and some more details, we need some programs - have to install:
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

# ################# Care about the package installer

# No idea on which system we are - but we could check which package manager we could use:
aptgetPresent=$(which apt-get 2> /dev/zero)
aptPresent=$(which apt 2> /dev/zero)
zypperPresent=$(which zypper 2> /dev/zero)
brewPresent=$(which brew 2> /dev/zero)
apkPresent=$(which apk 2> /dev/zero)
# Question: Which package manager for debian on chrome book? Answer: apt

# Maybe we haven't found a package manager. This could happen on a MAC OS X System without brew.
# Therefore check the system and try to install brew.
# TODO
if [ "$SYSTEM" = "MACOSX" ] && [ ! -x "$brewPresent" ] ; then
    echo "[$PROG_NAME:WARNING] Running on MAC OS X, but without 'brew'. Please install it."
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # -f No errors
    # -L Maybe get from new location
    # -s Silent or quiet mode. Do not show progress meter or error messages.
    # -S When used with -s, it makes curl show an error message if it fails.
    # If you want a non-interactive run of the Homebrew installer that doesn’t prompt for passwords (e.g. in automation scripts), 
    # prepend NONINTERACTIVE=1 to the installation command.
fi

# Template for installing packages for different systems:
#blaPresent=$(which bla)
#if [ -z "$blaPresent" ] ; then
    # TODO: aptgetPresent
#    if [ -x "$aptgetPresent" ] ;  then
#        $appSudo apt-get -y install TODOFillInPackageName
#    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # TODO: brewPresent
#    if [ -x "$brewPresent" ] ; then
#        $appSudo brew install TODOFillInPackageName
#    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
#fi

if [ "$DEPENDENCIES" = "1" ] ; then
    # We have copied all files and don't care about the dependencies:
    cleanUp
    echo "[$PROG_NAME:STATUS] Done."
    exit
fi

# Allways good idea to update the system, update typically updates the 
# package manager caches:
if [ "$SHORT" = "0" ] ; then
    packageManagerUpdate
    packageManagerCleaning
fi

if [ ! "$RASPUPGRADE" = "" ] ; then
    osUpgrade "$RASPUPGRADE"
fi

# Sometimes we should use an alternative package manager: snap
#snapPresent=$(which snap)
#if [ -z "$snapPresent" ] ; then
#    if [ -x "$aptgetPresent" ] ; then
#        $appSudo apt-get -y install snapd
#    fi
#    # TODO SuSE
#    # TODO MAC OS X
#fi
# ########################## ATTENTION ########################################
#
# snap is very ugly: To use snap, a re-login is needed. Therefore, in the same 
# script, snap can't installed and used.
# This means: we normally must do an logout now. Uaah.
#
# snap didn't work in docker: "System has not been booted with systemd as init system (PID 1). Can't operate."
# https://snapcraft.io/docs/troubleshooting
#
# More about snap:
# https://snapcraft.io/
# https://de.wikipedia.org/wiki/Snappy_(Paketverwaltung)

# 'lsb-release' is needed to detect on which Linux version we are running.
lsbreleasePresent=$(which lsb-release 2> /dev/zero)
if [ -z "$lsbreleasePresent" ] ; then
    # Sometimes a little bit different spelling:
    lsbreleasePresent=$(which lsb_release 2> /dev/zero)
fi
if [ -z "$lsbreleasePresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        # We could use apt-get:
        $appSudo apt-get -y install lsb-release
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install lsb-release  # NOT TESTED
    fi
    # TODO: brewPresent
    # TODO: apkPresent
fi
# Check, if we are successful:
lsbreleasePresent=$(which lsb-release 2> /dev/zero)
if [ -z "$lsbreleasePresent" ] ; then
    # Sometimes a little bit different spelling:
    lsbreleasePresent=$(which lsb_release 2> /dev/zero)
fi
if [ -z "$lsbreleasePresent" ] && [ -z "$brewPresent" ] ; then
    echo "[$PROG_NAME:WARNING] Can't find 'lsb-release' or 'brew'."
fi

# 'file' is not standard --> Install it:
filePresent=$(which file 2> /dev/zero)
if [ -z "$filePresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install file
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install file  # NOT TESTED
    fi
    # TODO: brewPresent
    # Installation was not working on iPhone - must be something different...
    #if [ -x "$apkPresent" ] ; then
    #    $appSudo apk add coreinfo # NOT TESTED
    #fi
fi

# Take care the bashutils core unix dependencies are present:
datePresent=$(which date 2> /dev/zero)
if [ -z "$datePresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install coreutils
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # brew: 'date' is standard
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# 'date' itself is so standard, there seems no need to install it.
# But there are a lot of interesting helper functions. 
# See: https://www.fresse.org/dateutils/
# For MAC OS X: https://formulae.brew.sh/formula/dateutils#default
#               brew install dateutils
# For Ubuntu: https://packages.ubuntu.com/search?keywords=dateutils
#               apt-get -y install dateutils
#
# INFO: Today not yet used. Therefore no install line.

# Take care the bashutils core unix dependencies are present:
#
# cut
#        Ubuntu: coreutils
#        MAC OS X: So standard, there seems no need to install it. No brew formulae exists.
#
# cat
#        Ubuntu: coreutils
#        MAC OS X: So standard, there seems no need to install it. No brew formulae exists.
#
# wc
#        Ubuntu: coreutils
#        MAC OS X: So standard, there seems no need to install it. No brew formulae exists.
#

# readline may be interesting
# See: https://tiswww.case.edu/php/chet/readline/rluserman.html

# Take care the bashutils core unix dependencies are present:
sedPresent=$(which sed 2> /dev/zero)
if [ -z "$sedPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install sed
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # brew: Available at MAC OS X as standard. With brew a gnu-sed could be installed instead.
    # https://formulae.brew.sh/formula/gnu-sed#default
#    if [ -x "$brewPresent" ] ; then
#        $appSudo brew install TODOFillInPackageName
#    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# 'git' we need to update this program suite --> Install it:
gitPresent=$(which git 2> /dev/zero)
if [ -z "$gitPresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install git
    fi
    # TODO: zypperPresent
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install git
    fi
    # TODO: apkPresent
fi
# If we want to contribute to this bashutils script on git, we have to set up
# the personnel git credentils by hand in ~/.ssh/
# TODO: Insert as comment the necessary steps which must be done manually.


# 'curl' we need for a lot of networking things --> Install it:
# iPad-von-Kasa:~# rki.sh # The program show these errors:
# /root/bin/rki.sh: line 101: curl: command not found 
# /root/bin/rki.sh: line 103: jq: command not found
curlPresent=$(which curl 2> /dev/zero)
if [ -z "$curlPresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install curl
    fi
    # TODO: zypperPresent
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install curl
    fi
    # TODO: apkPresent
fi

# 'socat' or 'netcat' is needed for cool network stuff.
# We try to do all things with socat to install only one tool.
# SOcket CAT: netcat on steroids
# http://www.dest-unreach.org/socat/
# MultiCast with UDP:  http://www.dest-unreach.org/socat/doc/socat-multicast.html
socatPresent=$(which socat 2> /dev/zero)
if [ -z "$socatPresent" ] ; then
    # TODO: aptgetPresent
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install socat
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    if [ -x "$brewPresent" ] ; then
        # https://formulae.brew.sh/formula/socat#default
        $appSudo brew install socat
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# 'wget' is not standard on MAC OS X
wgetPresent=$(which wget 2> /dev/zero)
if [ -z "$wgetPresent" ] ; then
    # TODO: aptgetPresent
#    if [ -x "$aptgetPresent" ] ;  then
#        $appSudo apt-get -y install TODOFillInPackageName
#    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install wget
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi


# oidc-agent is useful to connect to web services from bash scripts.
# https://indigo-dc.gitbook.io/oidc-agent/
# https://github.com/indigo-dc/oidc-agent
oidcPresent=$(which oidc-agent 2> /dev/zero)
if [ -z "$oidcPresent" ] ; then
    # TODO: aptgetPresent
    if [ -x "$aptgetPresent" ] ;  then
        # Debian 12 and newer / Ubuntu 22.04 and newer
        $appSudo apt-get -y install oidc-agent
        # TODO: No support under Raspbian GNU/Linux 9.13 (stretch)
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # TODO: brewPresent
    if [ -x "$brewPresent" ] ; then
        brew tap indigo-dc/oidc-agent
        $appSudo brew install oidc-agent
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

cryptPresent=$(which cryptsetup)
if [ -z "$cryptPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install cryptsetup
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # brewPresent: No need for cryptsetup under MAC, see devicemonitor.sh - getDiskSpace()
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# mDNS - Bonjour - ZeroConf
# See:
# https://atwillys.de/content/linux/mdns-on-debian-ubuntu-installation/
# https://andrewdupont.net/2022/01/27/using-mdns-aliases-within-your-home-network/
#
# Apple:  Bonjour
# Linux:  avahi
#
# Install:
# >: sudo apt-get install avahi-daemon
# >: sudo apt-get install avahi-utils
#
# Configure:
# /etc/avahi/avahi-daemon.conf
#
# After changing config: Restart service:
# >: sudo service avahi-daemon restart
# Showing status:
# >: sudo service avahi-daemon status

# 'jq' is often needed to deal with json data from REST-APIs.
# iPad-von-Kasa:~# rki.sh # The program show these errors:
# ...
# /root/bin/rki.sh: line 103: jq: command not found
#
# https://stedolan.github.io/jq/
# jq is like sed for JSON data - you can use it to slice and filter and map and 
# transform structured data with the same ease that sed, awk, grep and friends 
# let you play with text.
#
# Examples: 
# :> echo "{\"greeting\":\"Hallo Welt\"}" | jq -M
# :> jq --version
jqPresent=$(which jq 2> /dev/zero)
if [ -z "$jqPresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install jq
    fi
    # TODO: zypperPresent
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install jq
    fi
    # TODO: apkPresent
fi

# lesspipe and lessfile shows information on files.
# See:
# c't 2024-07, page 92
# https://manpages.ubuntu.com/manpages/focal/man1/lessfile.1.html

# I love 'joe' for fast text editing --> Install it:
joePresent=$(which joe 2> /dev/zero)
if [ -z "$joePresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install joe
    fi
    # TODO: zypperPresent
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install joe
    fi
    # TODO: apkPresent
fi

# croc is easy to use working on different systems:
# Securely send things from one computer to another - https://github.com/schollz/croc
crocPresent=$(which croc 2> /dev/zero)
if [ -z "$crocPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        #$appSudo apt-get -y install TODOFillInPackageName
        curl https://getcroc.schollz.com | bash
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install croc
    fi
    # TODO: apkPresent - Not yet tested
    if [ -x "$apkPresent" ] ; then
       # $appSudo apk add TODOFillInPackageName
        apk add bash coreutils  # For wget
        wget -qO- https://getcroc.schollz.com | bash
    fi
fi

# gnuplot to draw diagrams
gnuplotPresent=$(which gnuplot 2> /dev/zero)
if [ -z "$gnuplotPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install gnuplot-nox
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    #if [ -x "$brewPresent" ] ; then
        # macOS 10.13 is no more able to install with brew the gnuplot tool
    #    $appSudo brew install gnuplot
    #fi
    # TODO: apkPresent - Not yet tested
    #if [ -x "$apkPresent" ] ; then
    #   # $appSudo apk add TODOFillInPackageName
    #fi
fi

# qpdf to anaylse pdf files at command line
# https://github.com/qpdf/qpdf
# qpdf --qdf --object-streams=disable orig.pdf expanded.pdf
# Ubuntu: install qpdf
# MAC OS X: brew install qpdf

# ################# Care about the Environment

# Minimal "Bash rc" erzeugen, falls nicht vorhanden.
#
# ___
# .bashrc
# export PATH=$PATH:/root/bin
if [ ! -f "$HOME/.bashrc" ] ; then
    # Set default Path:
    tmpHome="$HOME"
    echo "export PATH=\$PATH:$tmpHome/bin" > "$HOME/.bashrc"
    # Set default Prompt:
    # \u : Username
    # \w : Working directory
    # \W : Last part of working directory
    # \h : Short version of hostname
    # \H : Full version of hostname
    echo "export PS1='\u@\h:\W>'" >> "$HOME/.bashrc"
    # Prepare for alias:
    echo "if [ -f ~/.bash_aliases ] ; then" >> "$HOME/.bashrc"
    echo "  . ~/.bash_aliases" >> "$HOME/.bashrc"
    echo "fi" >> "$HOME/.bashrc"
    # Generate alias file:
    if [ ! -f "$HOME/.bash_aliases" ] ; then
        echo "alias cd..=\"cd ..\"" > "$HOME/.bash_aliases"
    fi
fi
# Set path to directly work with:
export PATH="$PATH:$HOME/bin"

# Make sure all necessary tools are present:
uuidgenPresent=$(which uuidgen 2> /dev/zero)
if [ -z "$uuidgenPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install uuid-runtime
    fi
    if [ -x "$zypperPresent" ] ; then
        $appSudo zypper --non-interactive install uuid  # NOT TESTED
    fi
    # brew: Not found inside brew, but found on MAC OS X
    if [ -x "$apkPresent" ] ; then
        $appSudo apk add uuidgen
    fi
fi
uuidgenPresent=$(which uuidgen 2> /dev/zero)
if [ -z "$uuidgenPresent" ] ; then
    echo "[$PROG_NAME:ERROR] 'uuidgen' not installable. Exit."
    exit
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
# Maybe we need Python (more detailed: python3) on the system.
# https://wiki.python.org/moin/BeginnersGuide/Download
# brew install python3
#
# Than, we need also pip. pip is the package installer for Python.
# https://pip.pypa.io/en/stable/
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# python3 get-pip.py --user
#
# Upgrade pip:
# python3 -m pip install --upgrade pip

# ############# Network Section #############

# TODO
# Maybe we want to distribute software via ansible.
# https://docs.ansible.com/ansible/latest/getting_started/index.html
# https://docs.ansible.com/ansible/latest/getting_started/get_started_inventory.html
# https://docs.ansible.com/ansible/latest/user_guide/index.html
# https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html#yaml-syntax
# https://docs.ansible.com/ansible/latest/installation_guide/intro_configuration.html
# https://docs.ansible.com/ansible/latest/reference_appendices/config.html#environment-variables
# https://packages.ubuntu.com/jammy/python-ansible-runner-doc
# 
# python3 -m pip install --user ansible
# Installation under MacOS X is shitty: Will installed outside the path in: /Users/USERNAME/Library/Python/3.9/bin
#
# Upgrade ansible:
# python3 -m pip install --upgrade --user ansible
#
# Config ansible:
# 1. Generate config file with: ansible-config init --disabled > ansible.cfg
# 2. Change config file:
# inventory=~/.ansible/hosts
# local_tmp=~/tmp  
# log_path=~/tmp/ansible.log
# 3. Store config file: cp ansible.cfg ~/.ansible.cfg
# 4. Prepare that config works: touch ~/tmp/ansible.log
#
# USES
# For ansible, we need python 3.8 or higher

# TODO
# Maybe we need rsync for Backups
# --exclude='.DS_Store'
# --bwlimit=30          bandwith limit
#
# rsync --version       In first line of output, we see the program version number and protocol version number
#
# Links
# https://rsync.samba.org/
# https://wiki.ubuntuusers.de/rsync/
#
# Examples
# Copy from the folder:
#   Local Host ./rsynctest
# the complete folder content to:
#   Remote Host $HOME/tmp/rsynctest
# rsync -ave 'ssh -i ~/.ssh/id_raspi' ./rsynctest pi@192.168.0.23:tmp/
#
rsyncPresent=$(which rsync 2> /dev/zero)
if [ -z "$rsyncPresent" ] ; then
    if [ -x "$aptgetPresent" ] ; then
        $appSudo apt-get -y install rsync
    fi
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
# For ish: apk add nmap 
nmapPresent=$(which nmap 2> /dev/zero)
if [ -z "$nmapPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        # nmap is in: impish (21.10) - but did not work, package nmap works.
        $appSudo apt-get -y install nmap
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    if [ -x "$brewPresent" ] ; then
        $appSudo brew install nmap
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# network scan with nmap and arp OR with ip
ipPresent=$(which ip 2> /dev/zero)
if [ -z "$ipPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install iproute2
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
        # SuSE: arp is in package "net-tools-deprecated"
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    if [ -x "$brewPresent" ] ; then
        # https://formulae.brew.sh/formula/iproute2mac#default
        # MAC: ip like:  brew install iproute2mac --> See: https://github.com/brona/iproute2mac
        $appSudo brew install iproute2mac
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi

# Cool Program to work with websockets: https://github.com/websockets/wscat
# Install with: npm install -g wscat
# At the moment we dont't care about node.js components.

# caddy is a open source web server and reverse proxy
# See: 
#    https://caddyserver.com/
#    https://caddyserver.com/docs/quick-starts/api
caddyPresent=$(which caddy 2> /dev/zero)
if [ -z "$caddyPresent" ] ; then
    # Download to tmp dir:
    sActDir=$(pwd)
    cd "$TmpDir"
    # TODO: aptgetPresent
#    if [ -x "$aptgetPresent" ] ;  then
#        $appSudo apt-get -y install TODOFillInPackageName
        # Need to distinguish between different hardware architectures:
        # https://caddyserver.com/download
        # https://caddyserver.com/docs/install
        # For raspi:
        # https://caddyserver.com/api/download?os=linux&arch=arm&arm=7
#    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # TODO: brewPresent
#    if [ -x "$brewPresent" ] ; then
    if [ "$SYSTEM" = "MACOSX" ] ; then
#        $appSudo brew install TODOFillInPackageName
        # Very dirty system evaluation...
        # If there is a file named 'caddy': Rename it:
        if [ -e "./caddy" ] ; then
            mv ./caddy ./caddy_"$actDateTime"
        fi
        echo "[$PROG_NAME:STATUS] Try to download 'caddy' ..."
        wget "https://caddyserver.com/api/download?os=darwin&arch=amd64" -O caddy
        chmod u+x caddy
        # Check caddy:
        # caddy version string is e.g.: v2.6.4 h1:2hwYqiRwk1tf3VruhMpLcYTg+11fCdr8S3jhNAdnPy8=
        sCaddyVersion=$(./caddy version | cut -d " " -f 1)
        sCaddyTest=${sCaddyVersion:0:1}
        if [ "$sCaddyTest" = "v" ] ; then
            # It seems to be a known caddy version with runs on this architecture:
            mv ./caddy "$DestDir"
        fi
    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
    # Clean up:
    cd "$sActDir"
fi

# If we have MQTT or a webserver running, maybe we need something to authorize:
# OAuth 2
# https://snapcraft.io/moauth
# https://snapcraft.io/install/moauth/ubuntu

# ############# Multi Media Section #############

# TODO
# ffmpeg is a good tool to include images into mp3 files. See also: https://ffmpeg.org/
#  > ffmpeg -i BeispielInput.mp3 -i Bild.png -c copy -map 0 -map 1 BeispielOutput.mp3
# Explanation:
# The codec option for audio streams has been set to copy, so no decoding-filtering-encoding operations will occur, or can occur. 
# After that, maybe you want to delete the input file...
ipPresent=$(which ffmpeg 2> /dev/zero)
if [ -z "$ffmpegPresent" ] ; then
    if [ -x "$aptgetPresent" ] ;  then
        $appSudo apt-get -y install ffmpeg
    fi
    # TODO: zypperPresent
#    if [ -x "$zypperPresent" ] ; then
#        $appSudo zypper --non-interactive install TODOFillInPackageName
#    fi
    # TODO: Did not run under old MAC OS X 10.13 - test on Raspi
#    if [ -x "$brewPresent" ] ; then
#        $appSudo brew install ffmpeg
#    fi
    # TODO: apkPresent
#    if [ -x "$apkPresent" ] ; then
#        $appSudo apk add TODOFillInPackageName
#    fi
fi



# TODO
# Maybe we want to inform a server to have all necessary things installed?

cleanUp

echo "[$PROG_NAME:STATUS] Done."
