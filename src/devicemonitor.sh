#!/bin/bash

# #########################################
#
# Overview
#
# This script looks for the specific values of a device:
# - OS System Type
# - Used disk Space
# - CPU Usage
# - Memory Usage   <-- TODO
# - Last Update    <-- TODO
#
# The values could be:
# - printed on stdout
# - written to the file '$ConfInfoFile' which is by default '$HOME/devicemonitor/_Process/devicestatus.json'
#           Every time a new set of values is created, the old content of the file will be overwritten to
#           not use increasing disk space
# - send to a server defined in the configuration file
#
# The value sets written to file and send to server are the same json content with a time stamp for every set.
#
#
# Configuration
# 
# In the configuration file '.devicemonitor.ini' there are defined:
# - Server = Defines the server the values are send to as json
# - SerialNumber = Store the serial number of the system
# - DiskEncryption = Store the status of the disk encryption

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
# 2022-03-04 0.12 kdk Description: Ubuntu 20.04.3 LTS tested
# 2022-03-04 0.13 kdk Description: With ish
# 2022-04-01 0.14 kdk Description: Ubuntu 20.04.4 LTS
# 2022-04-08 0.15 kdk Description:    Debian GNU/Linux 10 (buster)
# 2022-05-02 0.16 kdk TODO and comments added, sendInfo(), writeInfo()
# 2022-05-13 0.17 kdk getCpuUsage() added
# 2022-05-18 0.18 kdk getSystem() enhanced to have text without "Description:   " prefix
# 2022-06-08 0.19 kdk -P added
# 2022-07-27 0.20 kdk -P changed from ProgramFolder to ProgramName
# 2022-08-03 0.21 kdk cputmp made more robust with sed 
# 2022-10-21 0.22 kdk 22.04.01 LTS added
# 2022-10-24 0.23 kdk Monterey added
# 2022-10-31 0.24 kdk MAC OS X 21.6.0 added
# 2022-11-07 0.25 kdk 'not yet supported' added
# 2022-11-10 0.26 kdk MAC OS X Ventura 13.0.1 added
# 2022-12-11 0.27 kdk Config file name adjusted to standard
# 2023-02-07 0.28 kdk MAC OS X Ventura 13.2 added
# 2023-02-07 0.29 kdk MAC OS X disk encryption status added
# 2023-03-10 0.30 kdk 21.3.0 added
# 2023-04-20 0.31 kdk Serial Number on Linux
# 2023-05-04 0.32 kdk 22.4.0 added
# 2023-11-08 0.33 kdk Hopefully error on raspi removed.
# 2023-11-13 0.34 kdk Remove \0 error, include "Ubuntu 22.04.03 LTS"
# 2023-11-17 0.35 kdk Ubuntu 22.04.3 LTS and Ubuntu 20.04.6 LTS added
# 2023-11-24 0.36 kdk getSystem() mode more robust and added: MAC OS X Sonoma 14.1.1, comments added.
# 2023-11-24 0.37 kdk Make it more stable and include getSerialNumber on more systems.
# 2024-01-17 0.38 kdk Disk Encryption under Ubuntu added
# 2024-01-21 0.39 kdk MAC OS X 23.2.0 added, GetDiskSpace-Linux-Encryption extended
# 2024-01-24 0.40 kdk Comments added.
# 2024-01-25 0.41 kdk Encryption optimised.

PROG_NAME="Device Monitor"
PROG_VERSION="0.41"
PROG_DATE="2024-01-25"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="devicemonitor.sh"

# #########################################
# 
# Hints
#
# The user name could be retrieved with 'whoami' on Linux and MAC OS X.
# At the moment not included here, because we want to get information about
# the system, not the user.

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2024 - 2021 Karsten Köth
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


# #########################################
#
# Constants
#

product="devicemonitor"

# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
DISKSPACE="0%"
DISKENCRYPTION="Unknown"
CPUUSAGE="0%"
SYSTEM="unknown"
    # Allowed values:
    # - MACOSX
    # - WIN
    # - LINUX
    # - SUSE
SYSTEMDescription="" # Will be filled if possible
SYSTEMTested="0" # If we detect a system, the script was tested on, we switch to "1"
MACADDRESS="00:00:00:00:00:00"
IP4ADDRESS="0.0.0.0"
SERIALNUMBER="unknown"
ARCHITECTURE="unknown"
    # Known values:
    # "uname -m" on "Raspi" with Linux shows: "armv7l"
    # "uname -m" on "Intel NUC" with "Ubuntu" shows: "x86_64"
    # "uname -m" on "Intel MacBook x86_64" shows: "x86_64"
RASPI="0"  # If we detect a raspberry, the script was tested on, we switch to "1"

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"
RUNONCE="0"

# Standard Folders and Files

MainFolder="_"
ControlFolder="_"
ProcessFolder="_"

RunFile="_"
LogFile="_"
MainLoopSleepFactor="10"    # Do the main task around every 10 seconds.
MainLoopResponseTime="1s"   # Reaction time of around 1 second to the "shut down" command given over file the system ('RunFile')

ConfigFile="_"              # Set in adjustVariables()
ConfServer=""               # Set in ConfigFile
ConfSerialNumber=""         # Set in ConfigFile
ConfDiskEncryption=""       # Set in ConfigFile
ConfInfoFile=""             # Set in adjustVariables()

# #########################################
#
# Functions
#

# #########################################
# adjustVariables()
# Parameter
# Sets the global variables 
function adjustVariables()
{
    # Linux like we should install e.g. under /opt/ or /usr/local/ - but we complete act inside home directory:
    MainFolder="$HOME/$product/"

    ControlFolder="$MainFolder""_Control/"
        RunFile="$ControlFolder""RUNNING"
        LogFile="$ControlFolder""LOG"

    ProcessFolder="$MainFolder""_Process/"
        ConfInfoFile="$ProcessFolder""devicestatus.json"

    ConfigFile="$HOME/.$product.ini"
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
# updateLog()
# Parameter
#    -
# Return Value
#    -
# Write time stamp into log file.
function updateLog()
{
    touch "$LogFile"
}

# #########################################
# updateRun()
# Parameter
#    -
# Return Value
#    -
# Write time stamp into run file.
function updateRun()
{
    touch "$RunFile"
}

# #########################################
# delFile()
# Parameter
#   1: File name
# Return Value
#    -
# Deletes a file, if it exists.
function delFile()
{
    if [ -f "$1" ] ; then
        rm "$1"
    fi
}

# #########################################
# removeRun()
# Parameter
#    -
# Return Value
#    -
# Removes the RunFile to show the program has finished.
function removeRun()
{
    delFile "$RunFile"
}

# #########################################
# checkExit()
# Parameter
#    - 
# Return Value
#    -
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
#    -
# Return Value
#    -
# Checks, if the shell script is running in another instance and exits if yes.
function checkStart()
{
  if [ -e "$RunFile" ]  ; then
    echo "[$PROG_NAME:ERROR] Maybe an older instance is running. If not: Delete '$RunFile' and start again. Exit."
    exit 
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
    checkOrCreateFile "$ConfigFile" "Configuration"
    if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Configuration file '$ConfigFile' not usable. Exit"; exit; fi

    checkOrCreateFolder "$MainFolder" "Main Program"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create main folder. Exit"; exit; fi
    checkOrCreateFolder "$ControlFolder" "Control"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create control folder. Exit"; exit; fi
    checkOrCreateFolder "$ProcessFolder" "Process"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create process folder. Exit"; exit; fi
}

# #########################################
# getConfig()
# Parameter
#    -
# Return Value
#    -
# Read out the variables from the config file.
function getConfig()
{
    # Similar to the old Windows file format. Variable name and variable content is delimited with a equal sign.
    # If more than one line of same variable: Take the latest.
    # Remove spaces before and after the variable content.
    ConfServer=$(cat "$ConfigFile" | grep -i "Server" | tail -n 1 | cut -d "=" -f 2 | sed "s/^ *//g" | sed "s/$ *//g")
    ConfSerialNumber=$(cat "$ConfigFile" | grep -i "SerialNumber" | tail -n 1 | cut -d "=" -f 2 | sed "s/^ *//g" | sed "s/$ *//g")
    ConfDiskEncryption=$(cat "$ConfigFile" | grep -i "DiskEncryption" | tail -n 1 | cut -d "=" -f 2 | sed "s/^ *//g" | sed "s/$ *//g")
}

# #########################################
# getSystem()
# Parameter
#    -
# Return Value
#    -
# Identifies the system type and changes the global variables: SYSTEM + SYSTEMDescription + SYSTEMTested
function getSystem()
{
    # Check, if program is available:
    unamePresent=$(which uname)
    if [ -z "$unamePresent" ] ; then
        echo "[$PROG_NAME:getSystem:ERROR] 'uname' not available. Exit"
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
            #                     e.g. "21.3.0" = MAC OS X 
            #                     e.g. "21.6.0" = MAC OS X Monterey 12.6
            #                     e.g. "22.1.0" = MAC OS X Ventura 13.0.1
            #                     e.g. "22.3.0" = MAC OS X Ventura 13.2
            #                     e.g. "22.4.0" = MAC OS X Ventura 13.3.1
            #                     e.g. "23.1.0" = MAC OS X Sonoma 14.1.1
            #                     e.g. "23.2.0" = MAC OS X Sonoma 14.2.1
            #                     e.g. "4.20.69-ish" = iPhone SE 14.5.1 with ish-App
            #                     e.g. "4.20.69-ish" = iPad Air 2 14.7.1 with ish-App
            # https://de.wikipedia.org/wiki/Darwin_(Betriebssystem)
            SYSTEMDescription=$(uname -r)
            SYSTEMTested="0"
            if [ ! -z "$SYSTEMDescription" ] ;  then
                if [ "$SYSTEMDescription" = "17.7.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "21.6.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "21.3.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "22.1.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "22.3.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "22.4.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "23.1.0" ] ; then
                    SYSTEMTested="1"
                fi
                if [ "$SYSTEMDescription" = "23.2.0" ] ; then
                    SYSTEMTested="1"
                fi
                # Normally, it is found under Linux, but maybe ... try it:
                if [ "$SYSTEMDescription" = "4.20.69-ish" ] ; then
                    SYSTEMTested="1"
                fi
                # ... Add more known and tested systems.
            fi
            # Be paranoid: If nothing found, be sure the string is clean:
            if [ "$SYSTEMTested" = "0" ] ; then
                echo "[$PROG_NAME:getSystem:Darwin:WARNING] Support for '$SYSTEMDescription' not yet implemented."
                SYSTEMDescription=""
            fi
        elif [ "$sSYSTEM" = "Linux" ] ; then
            SYSTEM="LINUX"
            # Set to Default:
            SYSTEMDescription=""
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
                        SYSTEMDescription="SUSE Linux Enterprise Server 15 SP1"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 18.04.6 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 18.04.6 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 20.04.3 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 20.04.3 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:    Ubuntu 20.04.4 LTS" ] ; then
                        # Inside Citrix Dedicated Desktop the "* Base WSL"
                        # Tested at 2022-04-01
                        SYSTEMDescription="Ubuntu 20.04.4 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 20.04.6 LTS" ] ; then
                        # Inside AWS
                        # Tested at 2023-11-17
                        SYSTEMDescription="Ubuntu 20.04.6 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 22.04.01 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.01 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 22.04.03 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.03 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Ubuntu 22.04.3 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.3 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:    Debian GNU/Linux 10 (buster)" ] ; then
                        # Chromebook
                        # Tested at 2022-04-08
                        SYSTEMDescription="Debian GNU/Linux 10 (buster)"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Description:	Raspbian GNU/Linux 9.13 (stretch)" ] ; then
                        # Tested at 2022-05-13
                        SYSTEMDescription="Raspbian GNU/Linux 9.13 (stretch)"
                        SYSTEMTested="1"
                    fi

                    # Newer version more tolerant against different systems: We do not compare the white spaces:
                    # "Description weg nehmen:  
                    SYSTEMDescription=$(echo "$SYSTEMDescription" | sed "s/Description://g" | sed "s/^[[:blank:]]*//g")

                    # And now test also the systems above:
                    if [ "$SYSTEMDescription" = "SUSE Linux Enterprise Server 15 SP1" ] ; then 
                        # The Script collection was tested on this system:
                        SYSTEMDescription="SUSE Linux Enterprise Server 15 SP1"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 18.04.6 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 18.04.6 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 20.04.3 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 20.04.3 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 20.04.4 LTS" ] ; then
                        # Inside Citrix Dedicated Desktop the "* Base WSL"
                        # Tested at 2022-04-01
                        SYSTEMDescription="Ubuntu 20.04.4 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 20.04.6 LTS" ] ; then
                        # Inside AWS
                        # Tested at 2023-11-17
                        SYSTEMDescription="Ubuntu 20.04.6 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 22.04.01 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.01 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 22.04.03 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.03 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Ubuntu 22.04.3 LTS" ] ; then
                        SYSTEMDescription="Ubuntu 22.04.3 LTS"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Debian GNU/Linux 10 (buster)" ] ; then
                        # Chromebook
                        # Tested at 2022-04-08
                        SYSTEMDescription="Debian GNU/Linux 10 (buster)"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Debian GNU/Linux 11 (bullseye)" ] ; then
                        # Chromebook
                        # Added at 2023-11-24
                        SYSTEMDescription="Debian GNU/Linux 11 (bullseye)"
                        SYSTEMTested="1"
                    fi
                    if [ "$SYSTEMDescription" = "Raspbian GNU/Linux 9.13 (stretch)" ] ; then
                        # Tested at 2022-05-13
                        SYSTEMDescription="Raspbian GNU/Linux 9.13 (stretch)"
                        SYSTEMTested="1"
                    fi

                    # ... Add more known and tested systems.

                fi
                # Be paranoid: If nothing found, be sure the string is clean:
                if [ "$SYSTEMTested" = "0" ] ; then
                    echo "[$PROG_NAME:getSystem:Linux:WARNING] Support for '$SYSTEMDescription' not yet implemented."
                    SYSTEMDescription=""
                fi
            else
                # No lsb_release:
                echo "[$PROG_NAME:getSystem:Linux:WARNING] 'lsb_release' not found."
            fi
            # If we have no info with lsb-release:
            if [ -z "$SYSTEMDescription" ] ; then
                SYSTEMDescription=$(uname -r)
                SYSTEMTested="0"
                if [ ! -z "$SYSTEMDescription" ] ;  then
                    if [ "$SYSTEMDescription" = "4.20.69-ish" ] ; then
                        SYSTEMTested="1"
                    fi
                    # ... Add more known and tested systems.
                fi
                if [ "$SYSTEMTested" = "0" ] ; then
                    echo "[$PROG_NAME:getSystem:Linux:uname:WARNING] Support for '$SYSTEMDescription' not yet implemented."
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
# Tested on:
#     System Type : MACOSX   +   System Version : 17.7.0
#     System Type : LINUX    +   System Version : Raspbian GNU/Linux 9.13 (stretch)
function getDiskSpace()
{
    if [ "$SYSTEM" = "LINUX" ] ; then
        if [ "$SYSTEMDescription" = "4.20.69-ish" ] ; then
            # Alpine Linux with BusyBox
            DISKSPACE=$(df -h / | tail -n 1 | xargs | cut -d " " -f 4)
        else
            # Runs on "Ubuntu 18.04.5":
            # Runs on "SUSE Linux Enterprise Server 15 SP1":
            # Runs on "openSUSE Leap 15.2":
            # Runs on "Ubuntu 20.04.4 LTS"
            DISKSPACE=$(df -h / --output=pcent | tail -n 1 | xargs)
            # We are looking also for encryption status of the disk:
            # Disk Encryption could be also monitored with: sudo dmsetup status
            # Could maybe also shown with: sudo ufw status
            # But always 'sudo' is required :-( 
            if [ ! -z "$ConfDiskEncryption" ] ; then
                # We take the Encryption status from the config file to avoid using sudo:
                DISKENCRYPTION="$ConfDiskEncryption"
            else
                # We need to search for the status:
                # Set the correct sudo, source code from install_bashutils_local.sh 
                appSudo="sudo"
                appUser=$(whoami)
                if [ "$appUser" = "root" ] ; then
                    appSudo=""
                fi
                # Try to use cryptsetup to get the status:
                local dEncrypt=$($appSudo cryptsetup status /dev/mapper/vgubuntu-root | head -n 1 | cut -d " " -f 3 | sed "s/\.//g")
                if [ "$dEncrypt" = "active" ] ; then
                    # Store Status:
                    echo "DiskEncryption = ""On" >> "$ConfigFile"
                    # If we run in a loop:
                    ConfDiskEncryption="On"
                    DISKENCRYPTION="$ConfDiskEncryption"
                elif [ "$dEncrypt" = "inactive" ] ; then
                    # Store Status:
                    echo "DiskEncryption = ""Off" >> "$ConfigFile"
                    # If we run in a loop:
                    ConfDiskEncryption="Off"
                    DISKENCRYPTION="$ConfDiskEncryption"
                else
                    echo "[$PROG_NAME:getDiskSpace:DiskEncryption:WARNING] Status code unknown"
                fi
            fi
        fi
    elif [ "$SYSTEM" = "MACOSX" ] ; then
        # Example:
        # Filesystem     Size   Used  Avail Capacity iused               ifree %iused  Mounted on
        # /dev/disk1s1   500G   431G    58G    89% 2908579 9223372036851867228    0%   /
        #sStringZ=$(df -H / | tail -n 1 | cut -d "%" -f 1)
        #DISKSPACE=$(echo ${sStringZ: -3}"%")
        DISKSPACE=$(df -H / | tail -n 1 | xargs | cut -d " " -f 5)
        # We are looking also for encryption status of the disk:
        fdesetupPresent=$(which fdesetup 2> /dev/zero )
        if [ ! -z "$fdesetupPresent" ] ; then
            fdeReturn=$(fdesetup status)
            if [ "$fdeReturn" = "FileVault is On." ] ; then
                DISKENCRYPTION="On"
            else
                DISKENCRYPTION="Off"
            fi
        fi
    else
        echo "[$PROG_NAME:getDiskSpace:WARNING] System type unknown. Can't get disk space."
    fi
}

# #########################################
# getCpuUsage()
# Parameter
#    -
# Return Value
#    -
# Get the cpu usage. Runs a minimum 1 second! - Change the global variable CPUUSAGE
# Tested on:
#     System Type : MACOSX   +   System Version : 17.7.0
#     System Type : LINUX    +   System Version : Raspbian GNU/Linux 9.13 (stretch)
# TODO: Test on Ubuntu 
function getCpuUsage()
{
    local cputmp

    if [ "$SYSTEM" = "LINUX" ] ; then
        # cpuline=$(head -n 1 /proc/stat)
        # /proc/stat contains usage and more
        # First line shows summary for all CPUs
        # Data fields explained e.g. here: https://www.idnt.net/en-US/kb/941772
        # 1 Text String "cpu"
        # 2	user	Time spent with normal processing in user mode
        # 3	nice	Time spent with niced processing in user mode
        # 4	system	Time spent running in kernel mode
        # 5	idle	Time spent doing nothing
        cputmp=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) ; }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat))
        #echo "[$PROG_NAME:getCpuUsage:WARNING] Not yet implemented."
    elif [ "$SYSTEM" = "MACOSX" ] ; then
        # top shows the actual cpu usage. 
        # top line with cpu shows e.g.:
        # CPU usage: 13.7% user, 15.39% sys, 71.53% idle 
        # CPU usage: 9.62% user, 5.90% sys, 84.47% idle 
        cputmp=$(top -l  2 | grep -E "^CPU" | tail -1 | awk '{ print $3 + $5 }') 
    else
        echo "[$PROG_NAME:getDiskSpace:WARNING] System type unknown. Can't get disk space."
        cputmp=0
    fi
    cputmp=$(echo $cputmp | sed s/,/./g)
    CPUUSAGE=$(LANG=C printf "%.0f%%" $cputmp)
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
    local GetMacApp=$(which ip)
    if [ ! -z "$GetMacApp" ] ; then
        # "ip" installed, go on ...
        # This code is from bashutils - devicescan.sh -getOwnMacAddress()
        # We take only the code, not the comments.
        # With 'ip addr show' we see all mac addresses and the corresponding ip addresses.
        if [ "$SYSTEM" = "LINUX" ] ;  then
            if [ -r "/sys/class/net/eth0/address" ] ; then
                MACADDRESS=$(cat /sys/class/net/eth0/address | tr "[:lower:]" "[:upper:]" | tail -n 1)
            else
                MACADDRESS=$(ip addr show | grep -i ether | sed "s/ether /;/g" | cut -d ";" -f 2 | sed "s/ /;/g" | cut -d ";" -f 1 | tr "[:lower:]" "[:upper:]" | tail -n 1)
            fi
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            MACADDRESS=$(ip -4 addr show | grep -i ether | sed "s/ether /;/g" | cut -d ";" -f 2 | tr "[:lower:]" "[:upper:]" | tail -n 1)
        else
            echo "[$PROG_NAME:getMacAddress:WARNING] System type unknown. Can't get own MAC address."
        fi
    else
        echo "[$PROG_NAME:getMacAddress:WARNING] 'ip' not found. With 'arp' not yet implemented. Can't get own MAC address."
    fi
}

# #########################################
# getIpAddress()
# Parameter
#    -
# Return Value
#    -
# Get IP address from ... ethernet interface - Change the global variable IP4ADDRESS
function getIpAddress()
{
    local GetMacApp=$(which ip)
    if [ ! -z "$GetMacApp" ] ; then
        # "ip" installed, go on ...
        # This code is from bashutils - devicescan.sh -getOwnIpAddress()
        # We take only the code, not the comments.
        if [ "$SYSTEM" = "LINUX" ] ;  then
            IP4ADDRESS=$(ip -o -4 addr show | grep -i global | head -n 1 | sed "s/  */;/g" | cut -f 4 -d ";" | cut -f 1 -d "/")
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            IP4ADDRESS=$(ip -4 addr show | grep -i brd | tail -n 1 | sed "s/  */;/g" | cut -f 2 -d ";" | cut -f 1 -d "/")
        else
            echo "[$PROG_NAME:getIpAddress:WARNING] System type unknown. Can't get own IP address."
        fi
    else
        echo "[$PROG_NAME:getIpAddress:WARNING] 'ip' not found. With 'arp' not yet implemented. Can't get own IP address."
    fi
}

# #########################################
# getSystemID()
# Parameter
#    -
# Return Value
#    -
# Get the individual ID we use to identify this system in an asset management system.
# Something like getSerialNumber().
function getSystemID()
{
    if [ "$SYSTEM" = "LINUX" ] ; then
        # Do we run on a raspi?
        #   Raspi:>  cat /proc/cpuinfo | grep -i hardware
        #   RETURN: Hardware	: BCM2835
        # ##################
        # Get Serial Number
        #   Raspi:>  cat /proc/cpuinfo | grep -i serial
        if [ -r /proc/cpuinfo ] ; then
            local RaspiCPU=$(cat /proc/cpuinfo | grep -i hardware | sed "s/[[:blank:]]*//g" | cut -d ':' -f 2)
            if [ "$RaspiCPU" = "BCM2835" ] ; then
                RASPI="1"
            fi
            # TODO: Test line above!
            # Test on big Raspi and on small Raspi.
        fi
        # More general:
        # Linux:> cat /sys/firmware/devicetree/base/serial-number
        if [ -r /sys/firmware/devicetree/base/serial-number ] ; then
            # This file contains a null terminated string. Therefore we have to treat it special:
            # Remove leading "0"
            # Remove trailing \0
            # Example:
            # hexdump -c /sys/firmware/devicetree/base/serial-number 
            #    0000000   0   0   0   0   0   0   0   0   1   e   9   e   e   6   7   5
            #    0000010  \0                     
            # Our output: "1e9ee675"
            SERIALNUMBER=$(cat /sys/firmware/devicetree/base/serial-number | sed "s/\0//g" | sed "s/\x00//g")
        else
            dmidecodePresent=$(which dmidecode 2> /dev/zero)
            if [ ! -z "$dmidecodePresent" ] ; then
                # For that programm we need root rights!
                # Under AWS EC2 this is no problem - no password is needed.
                # Under WSL the password must be given.
                # On Intel NUC with Ubuntu the password must be given.
                # Because we would need a password, we will do it only once on each system and store the information:
                # Variable set in getConfig()
                # local tmpSerialNumber=$(cat "$ConfigFile" | grep SerialNumber | cut -f 2 -d "=" | sed "s/^[[:blank:]]*//g")
                if [ ! -z "$ConfSerialNumber" ] ; then
                    SERIALNUMBER="$ConfSerialNumber"
                else
                    # We need to search for the number:
                    # Set the correct sudo, source code from install_bashutils_local.sh 
                    appSudo="sudo"
                    appUser=$(whoami)
                    if [ "$appUser" = "root" ] ; then
                        appSudo=""
                    fi
                    # Try to use dmidecode to get the serial number:
                    SERIALNUMBER=$($appSudo dmidecode -s system-serial-number | sed "s/^[[:blank:]]*//g")
                    if [ ! -z "$SERIALNUMBER" ] ; then
                        # Store Serial Number:
                        echo "SerialNumber = ""$SERIALNUMBER" >> "$ConfigFile"
                        # If we run in a loop:
                        ConfSerialNumber="$SERIALNUMBER"
                    else
                        echo "[$PROG_NAME:getSystemID:LINUX:WARNING] No serial number found with 'dmidecode'."
                    fi
                fi
            else
                # We need another solution ...
                echo "[$PROG_NAME:getSystemID:LINUX:WARNING] Not yet implemented on this linux system."
            fi
        fi
        # ##################
        # Get Product Name:
        # Linux:> cat /sys/firmware/devicetree/base/model 
        # RETURN: "Raspberry Pi 3 Model B Plus Rev 1.3"
        # Note: This is "ARMv7"
        # ##################
        # Get Processor Architecture:
        # "uname -m" on Raspi with Linux shows: "armv7l"
        # "uname -m" on "Intel NUC", with "Ubuntu" shows: "x86_64"
        ARCHITECTURE=$(uname -m)
        # Which architecture to support?
        # Useful combination of Architecture and OS:
        #  - linux-armv7
        #  - linux-x64
        #  - windows-x64
        #  - mac-x64
        #  - ...
    elif [ "$SYSTEM" = "MACOSX" ] ; then
        # ##################
        # Get Serial Number
        local systemProfPresent=$(which system_profiler 2> /dev/zero)
        if [ ! -z "$systemProfPresent" ] ; then
            # Get complete System Information and use only the line with serial number.
            # Remove trailing and leading spaces.
            SERIALNUMBER=$(system_profiler SPHardwareDataType | grep "Serial Number" | cut -d ":" -f 2 | sed "s/^ *//g" | sed "s/$ *//g")
            # Tested on MAC OS X 22.3.0
        else
            echo "[$PROG_NAME:getSystemID:LINUX:WARNING] No serial number found with 'system_profiler'."
        fi
        # ##################
        # Get Processor Architecture:
        # "uname -m" on "Intel MacBookx86_64" shows: "x86_64"
        ARCHITECTURE=$(uname -m)
        # Which strings with new Apple M* MACs?
        # With ':>sysctl -n machdep.cpu.brand_string'
        # Output:
        #   Intel based MacBook Air: 'Intel(R) Core(TM) i7-1060NG7 CPU @ 1.20GHz'
        #   Intel based Macbook Pro: 'Intel(R) Core(TM) i7-9750H CPU @ 2.60GHz'
        #   M1-based Macbook Air: 'Apple M1' 
        #   Macbook Pro 2021: 'Apple M1 Pro'
        #   Maybe other: 'Apple processor'
    else
        echo "[$PROG_NAME:getSystemID:Unknown:WARNING] Not yet implemented."
    fi
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
    echo "[$PROG_NAME:STATUS] System Type           : $SYSTEM"
    if [ "$SYSTEMTested" = "1" ] ; then
        echo "[$PROG_NAME:STATUS] System Version        : $SYSTEMDescription"
    fi
    echo "[$PROG_NAME:STATUS] Usage Disk Space      : $DISKSPACE"
    echo "[$PROG_NAME:STATUS]       Disk Encryption : $DISKENCRYPTION"
    echo "[$PROG_NAME:STATUS] Usage CPU Time        : $CPUUSAGE"
    if [ ! "$SERIALNUMBER" = "unknown" ] ; then
        echo "[$PROG_NAME:STATUS] Serial Number         : $SERIALNUMBER"
    fi
    if [ ! "$ARCHITECTURE" = "unknown" ] ; then
        echo "[$PROG_NAME:STATUS] Architecture          : $ARCHITECTURE"
    fi
    if [ "$RASPI" = "1" ] ; then
        echo "[$PROG_NAME:STATUS] Raspberry CPU"
    fi
    if [ ! "$MACADDRESS" = "00:00:00:00:00:00" ] ; then
        echo "[$PROG_NAME:STATUS] MAC Address           : $MACADDRESS"
    fi
    if [ ! "$IP4ADDRESS" = "0.0.0.0" ] ; then
        echo "[$PROG_NAME:STATUS] IP Address            : $IP4ADDRESS"
    fi
}

# #########################################
# createJSON()
# Parameter
#    -
# Return Value
#    JSON string
# Creates a JSON string for sendInfo() and writeInfo() on base of the global variables
function createJSON()
{
    local jstr
    jstr="{\"Date and Time\":\"$actDateTime\","                 # First line contains actual Date and Time
    jstr="$jstr""\"System Type\":\"$SYSTEM\","
    jstr="$jstr""\"System Version\":\"$SYSTEMDescription\","
    jstr="$jstr""\"Disk Space used\":\"$DISKSPACE\","
    jstr="$jstr""\"Disk Encryption\":\"$DISKENCRYPTION\","
    jstr="$jstr""\"CPU Time Usage\":\"$CPUUSAGE\","
    if [ ! "$SERIALNUMBER" = "unknown" ] ; then
        jstr="$jstr""\"Serial Number\":\"$SERIALNUMBER\","
    fi
    if [ ! "$MACADDRESS" = "00:00:00:00:00:00" ] ; then
        jstr="$jstr""\"MAC Address\":\"$MACADDRESS\","
    fi
    if [ ! "$IP4ADDRESS" = "0.0.0.0" ] ; then
        jstr="$jstr""\"IpAddress\":\"$IP4ADDRESS\","
    fi
                                                                # Here some values from plugins could be integrated
    local vstr
    vstr=$(showVersion)                                                               
    jstr="$jstr""\"Generator\":\"$vstr\"}"           # Last line with program version string
    echo "$jstr"
}

# #########################################
# sendInfo()
# Parameter
#    -
# Return Value
#    -
# Send the status information to an asset management system or to a monitoring solution
function sendInfo()
{
    echo "[$PROG_NAME:sendInfo:WARNING] Not yet implemented. Send to '$ConfServer'"
    # TODO sendInfo()
    # 1.) Develop a server process listen to the value set.
    # 2.) Send data from here with curl or wget
    # 3.) Comment in the call of this function in the main loop
    #
    # Concept
    # How to secure the connection? Could be done by using 'croc'.
    # Maybe 'scp' fits better. It is used by devicescan.sh - prepareConfig()
    # But: Then, every client needs write access to the server - unsecure. Not really:
    # If on the server every client has an own access, it is secure. --> create access pairs automatically.
    # Maybe its better, the client has an output folder and the server polls the clients.
    # But it should copied in a sub directory input folder in the server.
    # The client file is "$ConfInfoFile".
    # The server file should has a uuid as filename.
    # The server will find the file, move it from input to working and update his database.
    # The server will move it from working in done.
    # The 'asset management system' Server is defined in .devicemonitor.ini
    # 
    # Check, if $ConfServer is reachable
    #
    # Concept - Server with multiple access
    # Linux Server, e.g. Ubuntu on Intel NUC or on EC2
    # On Server: Create user with loginname and password
    # On Server: Create ~/devicemonitor/_Input
    # On Client: Use 'ssh-copy-id' to connect to server
    # On Client: Add server to .ssh/config
    # Client use 'scp' to store file on server. E.g. scp "$ConfInfoFile" ServerName:devicemonitor/_Input/"$UUIDFileName"
    # ServerName is the name of the server mentioned in ~/.ssh/config 
}

# #########################################
# writeInfo()
# Parameter
#    -
# Return Value
#    -
# Write the status information in JSON format to file.
function writeInfo()
{
    createJSON  > "$ConfInfoFile"
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
    echo "    -1     : Run script only once, not ongoing"
    echo "    -P     : Show Program Folder"
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
    if [ "$1" = "-1" ] ; then
        RUNONCE="1"
    elif [ "$1" = "-P" ] ; then
        echo "ProgramName=$product" ; exit;
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

# Init
adjustVariables
checkEnvironment
# Check, on which system we are running:
getSystem
getConfig
checkStart
updateRun

# Do something ...
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
getDiskSpace
getCpuUsage
getMacAddress
getIpAddress
getSystemID

# Show Info:
showInfo
writeInfo
#sendInfo # Not yet implemented.

if [ "$RUNONCE" = "1" ] ; then
    removeRun
    echo "[$PROG_NAME:STATUS] Done."
    exit
fi

# TODO: Check for robustness: Do all mentioned TODOs.

echo "[$PROG_NAME:STATUS] Enter main loop. Monitor script with ':> ls --full-time $LogFile'. Stop script by deleting '$RunFile'."

# Start main loop

while [ -f "$RunFile" ]
do
    updateLog
    # Do something:
    actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")
    getDiskSpace
    getCpuUsage # This command needs some seconds to be executed.
    updateLog
    getMacAddress
    getIpAddress
    getSystemID
    showInfo
    writeInfo
    #sendInfo # Not yet implemented.
    updateLog
    checkExit
done

# Done - clean up ...
removeRun

# End:
echo "[$PROG_NAME:STATUS] Done."
