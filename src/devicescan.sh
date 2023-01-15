#!/bin/bash

# #########################################
#
# Overview
#
# This script scans ip addresses in the local network
#
#
# Config File
#
# The location and name of the config file is: $HOME/.devicescan.ini
#
# [Clients] Section 
# Distribute the 'Devices File' to all clients:
# scp "$DevicesFile" raspi:  # "raspi" must be included in file ~/.ssh/config
#                            # ":" means: Copy into home directory
# Example for ~/.ssh/config :
# Host raspi
#   Hostname 192.168.0.23
#   User pi
#   IdentityFile ~/.ssh/id_raspi
#
# To distribute the 'Devices File' to other clients: Add the name of the 
# client as mentioned in the ssh config to the config file of this program.
# Example for ~/.devicescan.ini :
# Client = raspi


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
# 2022-03-30 0.04 kdk With more comments and ip
# 2022-05-02 0.05 kdk Error with error message fixed
# 2022-05-30 0.06 kdk Go on with more STATUS output and getOwnIpAddress(), tested on Raspi
# 2022-06-08 0.07 kdk -P added
# 2022-07-27 0.08 kdk -P changed from ProgramFolder to ProgramName, not yet tested
# 2022-09-23 0.09 kdk Minor changes, adjustVariables() called in main()
# 2022-11-01 0.10 kdk Scan under MAC OS X with 'ip'
# 2022-11-25 0.11 kdk Bug inside MAC OS X 'ip' part removed
# 2022-12-09 0.12 kdk Distribution half done
# 2022-12-11 0.13 kdk Go on with distribution
# 2023-01-14 0.14 kdk Print out changed
# 2023-01-14 0.15 kdk Copy correct file
# 2023-01-15 0.16 kdk Comments added

PROG_NAME="Device Scan"
PROG_VERSION="0.16"
PROG_DATE="2023-01-15"
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
# ip - Ubuntu paket "iproute2"
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
# Copyright 2023 - 2021 Karsten Köth
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

product="devicescan"

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

SYSTEM="unknown"

MACADDRESS="00:00:00:00:00:00"
IP4ADDRESS="0.0.0.0"
IP4SUBNET="0.0.0.*"

# Standard Folders and Files

MainFolder="_"
ControlFolder="_"
SummaryFolder="_"

RunFile="_"
LogFile="_"

TmpDir="_"
TmpFile="_"
ScanFile="_"
MacFile="_"
DevicesFile="_"
ConfigFile="_"

UserDatabaseFile="$HOME/Documents/Infrastruktur/Netzwerk.txt"

GetMacApp="-"
PrepConf="0"

# #########################################
#
# Functions
#

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
            echo "[$PROG_NAME:STATUS] $2 folder created."
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
            echo "[$PROG_NAME:STATUS] $2 file created."
        else
            echo "[$PROG_NAME:ERROR] $2 file could not be created."
            return 1
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

    ControlFolder="$MainFolder""_Control/"
        RunFile="$ControlFolder""RUNNING"
        LogFile="$ControlFolder""LOG"

    SummaryFolder="$MainFolder""_Summary/"

    TmpDir="$HOME/tmp/"
    TmpFile="$TmpDir""devicescan_nmap_$actDateTime.txt"
    ScanFile="devicescan_devices_$actDateTime.txt"
    MacFile="devicescan_mac_$actDateTime.txt"

    ConfigFile="$HOME/.$product.ini"
    DevicesFile="$HOME/.$product.csv"

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

    checkOrCreateFile "$TmpFile" "Temporary"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Temporary file '$TmpFile' not usable. Exit"; exit; fi

    checkOrCreateFolder "$MainFolder" "Main Program"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create main folder. Exit"; exit; fi
    checkOrCreateFolder "$ControlFolder" "Control"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create control folder. Exit"; exit; fi
    checkOrCreateFolder "$SummaryFolder" "Summary"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create summary folder. Exit"; exit; fi

    checkOrCreateFile "$ConfigFile" "Configuration"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Configuration file '$ConfigFile' not usable. Exit"; exit; fi
    checkOrCreateFile "$DevicesFile" "Devices"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Devices file '$DevicesFile' not usable. Exit"; exit; fi
    
    nmapProgram=$(which nmap)
        if [ -z "$nmapProgram" ] ; then echo "[$PROG_NAME:ERROR] Necessary program 'nmap' not found. Exit"; exit; fi

    GetMacApp=$(which ip)
    if [ -z "$GetMacApp" ] ; then
        # "ip" not installed, maybe we have "arp":
        GetMacApp=$(which arp)
        if [ -z "$GetMacApp" ] ; then
            # We have nothing:
            echo "[$PROG_NAME:ERROR] Necessary program 'arp' or 'ip' not found. Exit"; exit;
        else
            # We have "arp":
            GetMacApp="arp"
        fi
    else
        # We have "ip":
        GetMacApp="ip"
        # But which Version?
        # Program code from file "devicemonitor.sh" and function "getSystem()"):
        unamePresent=$(which uname)
        if [ -z "$unamePresent" ] ; then
            echo "[$PROG_NAME:ERROR] 'uname' not available. Exit"
            exit
        else
            sSYSTEM=$(uname -s) 
            # Detect System:
            if [ "$sSYSTEM" = "Darwin" ] ; then
                SYSTEM="MACOSX"
            elif [ "$sSYSTEM" = "Linux" ] ; then
                SYSTEM="LINUX"
            else
                echo "[$PROG_NAME:WARNING] System '$sSYSTEM' unknown."
            fi
        fi
    fi
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
#    Host Name
# The result will be written to stdout
function getHostname()
{
    cat "$DevicesFile" | grep "$1" | cut -d ";" -f 2
}

# #########################################
# getCompany()
#
# The MAC address ranges belongs to different companies.
# E.g. https://macaddress.io/  or  https://macvendors.com/   
# gives back the name of the company to a specific address.
# Some interesting companies:
# 80:04:5F:00:00:00 --> Apple, Inc
# 90:84:0D:00:00:00 --> Apple, Inc
# 00:F7:6F:00:00:00 --> Apple, Inc
# A4:E9:75:00:00:00 --> Apple, Inc
# 9C:35:EB:00:00:00 --> Apple, Inc
# 40:B3:95:00:00:00 --> Apple, Inc
# F0:79:60:00:00:00 --> Apple, Inc
# 00:06:77:00:00:00 --> Sick AG
# B8:27:EB:00:00:00 --> Raspberry Pi Foundation
# F8:DC:7A:00:00:00 --> Variscite Ltd ->- used by ->- Sick AG, Product TDC-E


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

    local NoOwn="1"

    # ip -4 neigh : Shows the ip and mac addresses in one line, e.g.:
    # 192.168.0.176 dev eth0 lladdr 68:5b:35:be:43:49 REACHABLE
    # 192.168.0.220 dev eth0  FAILED
    # Show only lines with MAC Addresses and show with uppercase letters:
    # ip -4 neigh | grep ":" | tr "[:lower:]" "[:upper:]"
    # IP  Address: cut -d " " -f 1
    # MAC Address: cut -d " " -f 5   <-- Could be non present, check for "contains 5 : ", see above
    if [ "$GetMacApp" = "ip" ] ; then
        # The new way with "ip", works under MACOSX and LINUX
        echo "[$PROG_NAME:listMacAddresses:STATUS] Searching by 'ip' ..."
        if [ "$SYSTEM" = "LINUX" ] ;  then
            ip -4 neigh | grep ":" | tr "[:lower:]" "[:upper:]" | sed "s/ /;/g"> "$TmpDir$MacFile.ip"
        elif [ "$SYSTEM" = "MACOSX" ] ;  then
            # Adaption under MACOSX:
            # Output e.g.: '192.168.0.164;DEV;EN4;LLADDR;60:3:8:C0:F6:C1;REACHABLE'
            # Need to enhance MAC addresses to have always 2 digits in every section: '60:3:... --> 60:03:...'
            # Same problem as below in 'arp' session.
            ip -4 neigh | grep ":" | tr "[:lower:]" "[:upper:]" | sed "s/ /;/g"> "$TmpDir$MacFile.mac"
            # Line starts not with MAC address. Therefore '^' is not before MAC, instead ';' is before MAC
            # Bug: Is missing: sed "s/:\(.\);/:0\1;/" | 
            # Line ends not with MAC address. Therefore '$' is not after MAC, instead ';' is after MAC 
            # Four times possible inside ':' and ':'
            cat "$TmpDir$MacFile.mac" | sed "s/;\(.\):/;0\1:/g" | sed "s/:\(.\);/:0\1;/g" |\
            sed "s/:\(.\):/:0\1:/g" | sed "s/:\(.\):/:0\1:/g" | sed "s/:\(.\):/:0\1:/g" | sed "s/:\(.\):/:0\1:/g" |\
            mac_converter.sh -L > "$TmpDir$MacFile.ip"
        fi
        # TODO
        # Under WSL openSuSE the function "neigh" is not supported by ip

        lines=$(cat "$TmpDir$MacFile.ip")

        for line in $lines
        do
            # You get this list also with: 'ip neighbour'
            #echo "'$line'"
            newLineMAC=$(echo "$line" | cut -d ";" -f 5)
            newLineIP=$(echo "$line" | cut -d ";" -f 1)
            newLineName=$(getHostname "$newLineMAC")
            newLine="$newLineMAC;$newLineIP;$newLineName;"
            # TODO: Remove Multicast addresses from list:
            # https://de.wikipedia.org/wiki/Multicast:
            # Bei IPv4 werden die untersten 23 Bit der IP-Adresse in die MAC-Adresse 01-00-5e-00-00-00 eingesetzt, 
            # wodurch sich Adressen aus dem Bereich von 01-00-5e-00-00-00 bis 01-00-5e-7f-ff-ff ergeben können. 
            # Hierbei wird bewusst in Kauf genommen, dass mehrere IPv4-Adressen auf dieselbe MAC-Adresse abgebildet 
            # werden (zum Beispiel 224.0.0.1 und 233.128.0.1).
            echo "'$newLine'"
            # TODO: In der Device List taucht der localhost, also das eigene Device, nicht auf.
            if [ "$IP4ADDRESS" = "$newLineIP" ] ; then
                # We have the own IP address in the list:
                NoOwn="0"
            fi
        done
        
        if [ "$NoOwn" = "1" ] ; then
            # The own ip address was not part of the list. Therefore add this:
            newLineMAC="$MACADDRESS"
            newLineIP="$IP4ADDRESS"
            newLineName=$(getHostname "$newLineMAC")
            newLine="$newLineMAC;$newLineIP;$newLineName;"
            echo "'$newLine'"
        fi
    fi

    # #####################################
    # arp - Version

    if [ "$GetMacApp" = "arp" ] ; then
        # The old way with "arp"
        echo "[$PROG_NAME:listMacAddresses:STATUS] Searching by 'arp' ..."

        # If first the network was scanned, the arp cache is filled.
        arp -a > "$TmpDir$MacFile.arp"
        # Filter the output to have only a list of MAC addresses:
        cat "$TmpDir$MacFile.arp" | cut -f 4 -d " " | grep ":" > "$TmpDir$MacFile.mac"
        # Make clean:
        # Enhance at the beginning from 1 char to 2 chars:   sed "s/^\(.\):/0\1:/g"
        # Enhance in the middle from 1 char to 2 chars:      sed "s/:\(.\):/:0\1:/g"
        # Enhance at the end from 1 char to 2 chars:         sed "s/:\(.\)$/:0\1/g"
        cat "$TmpDir$MacFile.mac" | sed "s/^\(.\):/0\1:/g" | sed "s/:\(.\)$/:0\1/g" | sed "s/:\(.\):/:0\1:/g" | sed "s/:\(.\):/:0\1:/g" | mac_converter.sh -L -x > "$TmpDir$MacFile"
    
    fi

    # TODO: Remove "#"
    # Clean up:
    #delFile "$TmpDir$MacFile.arp"
    #delFile "$TmpDir$MacFile.mac"
    #delFile "$TmpDir$MacFile.ip"
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
    echo "[$PROG_NAME:STATUS] Scanning network '$1' ..."
    # Lists all devices (which could be pinged) into file:
    nmap -sn "$1" -oG "$TmpFile"
    # Typical line in file: 
    # Host: 192.168.0.1 (kabelbox.local)	Status: Up
    # Extract ip addresses into next file:
    cat "$TmpFile" | grep "Host" | cut -f 2 -d " " > "$TmpDir$ScanFile"
    # Scan each device exactly
    # for ...
    echo "[$PROG_NAME:DEBUG] TODO"
}

# #########################################
# getOwnMacAddress()
# Parameter
#    -
# Return Value
#    -
# Try to find the most important mac address and write it to the global variable MACADDRESS
function getOwnMacAddress()
{
    if [ "$GetMacApp" = "ip" ] ; then
        if [ "$SYSTEM" = "LINUX" ] ;  then
            MACADDRESS=$(cat /sys/class/net/eth0/address | tr "[:lower:]" "[:upper:]")
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            MACADDRESS=$(ip -4 addr show | grep -i ether | sed "s/ether /;/g" | cut -d ";" -f 2)
        fi
        echo "[$PROG_NAME:getOwnMacAddress:DEBUG] '$MACADDRESS'"
    fi
}

# #########################################
# getOwnIpAddress()
# Parameter
#    -
# Return Value
#    -
# Try to find the most important ip address and write it to the global variable IP4ADDRESS
function getOwnIpAddress()
{
    if [ "$GetMacApp" = "ip" ] ; then
        #local tmpadr="0.0.0.0"
        if [ "$SYSTEM" = "LINUX" ] ;  then
            # Under "Raspbian GNU/Linux 9.13 (stretch)": Parameter -o is implemented and generates 1 line per interface:
            IP4ADDRESS=$(ip -o -4 addr show | grep -i global | sed "s/  */;/g" | cut -f 4 -d ";" | cut -f 1 -d "/")
            #tmpadr=$(ip -o -4 addr show | grep -i global | sed "s/  */;/g")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
            #tmpadr=$(echo "$tmpadr" | cut -f 4 -d ";")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
            #tmpadr=$(echo "$tmpadr" | cut -f 1 -d "/")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            # Under MACOSX "17.7.0": Parameter -o is not implemented
            IP4ADDRESS=$(ip -4 addr show | grep -i brd | sed "s/  */;/g" | cut -f 2 -d ";" | cut -f 1 -d "/")
        fi
        # TODO
        # It is possible to have more than one line in the variable 'IP4ADDRESS'. Check and search the most important.
        # But also with 2 addresses it is possible to have no connection to the internet.
        echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$IP4ADDRESS'"
        # TODO
        # Under WSL openSuSE there are 6 addresses found:
        # eth0 + wifi1 + wifi2 in 169.254.* subnet
        # eth1 in local net for LAN
        # wifi0 in local net for WIFI
        # lo as localhost with 127.0.0.1
    fi
}

# #########################################
# getOwnIpSubnet()
# Parameter
#  1 - ip address inside the subnet
# Return Value
#    -
#
function getOwnIpSubnet()
{
    sTmp1=$(echo "$IP4ADDRESS" | cut -f 1 -d ".")
    sTmp2=$(echo "$IP4ADDRESS" | cut -f 2 -d ".")
    sTmp3=$(echo "$IP4ADDRESS" | cut -f 3 -d ".")
    IP4SUBNET="$sTmp1.$sTmp2.$sTmp3.*"
}

# #########################################
# prepareConfig()
# Parameter
#    -
# Return Value
#    -
# Prepare configuration file
function prepareConfig()
{
    # TODO
    # Find over UDP Broadcast a server distributing configurations

    # TODO
    # Find over UDP Broadcast a client accepting configuration files

    # Try to find user based database file
    # cat ~/Documents/Infrastruktur/Netzwerk.txt | grep ";" | grep "$1" | cut -d ";" -f 2
    if [ -f "$UserDatabaseFile" ] ; then
        cat "$UserDatabaseFile" | grep ";" > "$DevicesFile"
        #echo "[$PROG_NAME:prepareConfig:DEBUG] Devices file filled."
    fi

    # Distribute the 'Devices File' to all clients:
    # scp "$DevicesFile" raspi:  # "raspi" must be included in file ~/.ssh/config
    #                            # ":" means: Copy into home directory
    # Example for ~/.ssh/config :
    # Host raspi
	#   Hostname 192.168.0.23
	#   User pi
	#   IdentityFile ~/.ssh/id_raspi
    #
    # To distribute the 'Devices File' to other clients: Add the name of the 
    # client as mentioned in the ssh config to the config file of this program.
    # Example for ~/.devicescan.ini :
    # Client = raspi
    #
    # Go trough the configfiles and copy file to all targets
    lines=$(cat "$ConfigFile" | grep -i "Client")

    # Separation only by newline, not by any whitespaces (set -f turns off globbing, i.e. wildcard expansion):
    IFS='
'
    for line in $lines
    do
        #echo "[$PROG_NAME:prepareConfig:DEBUG] Client line: '$line'"
        # The section heading "Clients" matches also to the search string "Client", Check for variables line:
        variableFound=$(echo "$line" | grep "=")
        if [ ! -z "$variableFound" ] ; then            
            # Similar to getConfig() in devicemonitor.sh:
            target=$(echo "$line" | cut -d "=" -f 2 | sed "s/^ *//g" | sed "s/$ *//g")
            targetFound=$(cat "$HOME/.ssh/config" | grep "$target")
            if [ -z "$targetFound" ] ; then
                echo "[$PROG_NAME:prepareConfig:WARNING] Client '$target' not found in ssh config."
            else
                # Not sure, if its a good idea to copy the config file ...
                scp "$ConfigFile" "$target":
                # This file contains the link between hostname and MAC address:
                scp "$DevicesFile" "$target":
            fi
        fi
    done
    unset IFS
    #echo "[$PROG_NAME:prepareConfig:DEBUG] Devices file distributed to all clients."
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
    echo "    -c     : Prepare configuration file"
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
    if [ -f "$1" ] ; then
        echo "[$PROG_NAME:STATUS] Input file exists."
    elif [ "$1" = "-c" ] ; then
        PrepConf="1"
    elif [ "$1" = "-P" ] ; then
        echo "ProgramName=$product" ; exit;
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    fi
fi

echo "[$PROG_NAME:STATUS] Check folders ..."
adjustVariables
checkEnvironment

if [ "$PrepConf" = "1" ] ; then
    prepareConfig 
    echo "[$PROG_NAME:STATUS] Done."
    exit
fi

getOwnMacAddress
getOwnIpAddress
getOwnIpSubnet "$IP4ADDRESS"
scanNetwork "$IP4SUBNET" 

echo "[$PROG_NAME:STATUS] Get MAC addresses ..."
listMacAddresses

# Maybe TODO: Delete all created tmp files.

echo "[$PROG_NAME:STATUS] Done."
