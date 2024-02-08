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
# Example for $HOME/.devicescan.ini :
# [Clients]
# Client = raspi
#
#
# Devices File
#
# The location and name of the devices file is: $HOME/.devicescan.csv
#
# The devices file defines the link between the MAC address and the device name.
# Example for $HOME/.devicescan.csv :
# 40:2B:50:12:AB:34;Kabelbox Router

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
# 2023-01-18 0.17 kdk Comments and isMultiCastMacAddress() added
# 2023-01-25 0.18 kdk Comments added
# 2023-02-16 0.19 kdk setDeviceStatus() added and tested on MAC
# 2023-05-01 0.20 kdk Comments added, drawDevicesStatus() added but not yet finished
# 2023-05-02 0.21 kdk Go on with drawDevicesStatus(), single files done. small test done.
# 2023-05-04 0.22 kdk Go on with drawDevicesStatus(), see TODO
# 2023-05-05 0.23 kdk Nearly done with draw
# 2023-06-27 0.24 kdk Bug with multiple networks removed. 
# 2023-10-30 0.25 kdk Bug with wrong MAC addresses removed.
# 2023-11-02 0.26 kdk Bug in getOwnMacAddress() for Ubuntu Linux removed
# 2023-11-03 0.28 kdk Comment added
# 2023-11-05 0.29 kdk getCompany() implemented.
# 2023-11-13 0.30 kdk Another MAC Address for Dell included
# 2023-11-24 0.31 kdk Bug removed in listMacAddresses() regarding 'ls -1'
# 2023-11-24 0.32 kdk Bug more removed
# 2024-01-17 0.33 kdk More Bugs removed
# 2024-02-08 0.34 kdk Scan tasks improved, $LinesFile added.

PROG_NAME="Device Scan"
PROG_VERSION="0.34"
PROG_DATE="2024-02-08"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="devicescan.sh"

# #########################################
#
# TODOs
#
# Support RunFile and LogFile
#
# getOwnMacAddress() - support full multiple networks
#
# Generated html file: src=\"https://cdn.plot.ly/plotly-latest.min.js\" will be loaded every time 
# the html file is loaded. Maybe we include the js-file in the html file for poor internet connections.
# Chrome caches the js file, therefore no urgent need to enhance this script.
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
# gnuplot <-- no more needed
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
# Constants
#

product="devicescan"

# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d_%H:%M:%S")
actDate=$(date "+%Y-%m-%d") # Corresponds to format inside gnuplot script
actTime=$(date "+%H:%M:%S")

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
DataFolder="_"
GraphFolder="_"
ScriptFolder="_"

RunFile="_"
LogFile="_"

TmpDir="_"
TmpFile="_"
ScanFile="_"
MacFile="_"
LinesFile="_"
KnownDevicesFile="" # We test with '-s'. Therefore the useless string should be empty.
DevicesFile="_"
ConfigFile="_"

UserDatabaseFile="$HOME/Documents/Infrastruktur/Netzwerk.txt"

GetMacApp="-"
PrepConf="0"
GnuPlotBinary="-"
DrawScript="-"

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
    DataFolder="$MainFolder""_Data/"
    GraphFolder="$MainFolder""_Graphs/"
    ScriptFolder="$MainFolder""src/"

    TmpDir="$HOME/tmp/"
    TmpFile="$TmpDir""devicescan_nmap_$actDateTime.txt"
    ScanFile="devicescan_devices_$actDateTime.txt"
    MacFile="devicescan_mac_$actDateTime.txt"
    LinesFile="devicescan_lines_$actDateTime.txt"
    KnownDevicesFile="$TmpDir""devicescan_knowndevices_$actDateTime.txt"

    ConfigFile="$HOME/.$product.ini"
    DevicesFile="$HOME/.$product.csv"

    DrawScript="$ScriptFolder""devicescan.gnuplot"
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
    checkOrCreateFolder "$DataFolder" "Data"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create data folder. Exit"; exit; fi
    checkOrCreateFolder "$GraphFolder" "Graph"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create graph folder. Exit"; exit; fi
    checkOrCreateFolder "$ScriptFolder" "Script"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create script folder. Exit"; exit; fi

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

    # Gnuplot to generate diagrams:
    isGnuplot=$(gnuplot -V 2> /dev/null)
    if [ -z "$isGnuplot" ] ; then
        #echo "[$PROG_NAME:WARNING] Gnuplot not found."
        #exit              # --> ERROR
        GnuPlotBinary="-"  # --> WARNING
    else
        GnuPlotBinary="gnuplot"
    fi
    # Gnuplot needs a script file:
    if [ ! -f "$DrawScript" ] ; then
        #echo "[$PROG_NAME:WARNING] Gnuplot Script not found."
        GnuPlotBinary="-"
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
# isMacAddress()
# Parameter
#    MAC Address (in upper Case)
# Return value
#   0 = Parameter is a valid MAC address
#   1 = An error occured
# Checks if the parameter is a valid MAC address
# Check return value e.g. with: if [ $? -eq 1 ] ; then echo "There was an error"; fi
function isMacAddress()
{
    # A MAC address has 12 alphanumerical values and 5 double dashes. In summary 17 characters.
    # Test strlen:
    local testmac="$1"
    strlen=${#testmac}
    if [ $strlen -ne 17 ] ; then return 1; fi
    #
    if [ ${testmac:2:1} != ":" ] || [ ${testmac:5:1} != ":" ] || [ ${testmac:8:1} != ":" ] || \
       [ ${testmac:11:1} != ":" ] || [ ${testmac:14:1} != ":" ] ; then return 1; fi
    # All tests are fine:
    return 0
}
# Function tested with:
# isMacAddress "01:23:45:67:89:AB" ;  if [ $? -eq 1 ] ; then echo "[$PROG_NAME:WARNING] Invalid MAC address '1'.";  fi
# isMacAddress "01:23:45:67:89:B" ;   if [ $? -eq 1 ] ; then echo "[$PROG_NAME:WARNING] Invalid MAC address '2'.";  fi
# isMacAddress "01:23:45:67:89:ABc" ; if [ $? -eq 1 ] ; then echo "[$PROG_NAME:WARNING] Invalid MAC address '3'.";  fi
# isMacAddress "" ;                   if [ $? -eq 1 ] ; then echo "[$PROG_NAME:WARNING] Invalid MAC address '4'.";  fi

# #########################################
# getHostname()
# Parameter
#    MAC Address (in upper Case)
# Return Value
#    Host Name
# The result will be written to stdout
function getHostname()
{
    local myreturnvalue=""
    # First, we have to check if the parameter is a valid MAC address. 
    # If the parameter is "", then all lines in the devicefile matches and the
    # return value contains multiple lines.
    isMacAddress "$1"
        if [ $? -eq 1 ] ; then 
            echo "[$PROG_NAME:WARNING] Invalid MAC address '$1'."
            myreturnvalue=""
            return
        fi
    # Parameter is ok. Get name:
    myreturnvalue=$(cat "$DevicesFile" | grep "$1" | cut -d ";" -f 2)

    if [ "$myreturnvalue" == "" ] ; then
        # MAC Address not in file of known MAC Addresses. Try to get Company of this MAC Address:
        myreturnvalue=$(getCompany "$1")
    fi
    echo "$myreturnvalue"
}

# #########################################
# getCompany()
# Parameter
#    MAC Address
# Return Value
#    Company Name for this MAC Address
# The MAC address ranges belongs to different companies.
# E.g. https://macaddress.io/  or  https://macvendors.com/   
# gives back the name of the company to a specific address.
# Some interesting companies:
# 68:5B:35:00:00:00 --> Apple, Inc
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
# 48:21:0B:00:00:00 --> Intel
# 0a:59:50:00:00:00 --> Intel
# 34:60:F9:00:00:00 --> TP-Link
# B4:45:06:00:00:00 --> Dell
# CC:48:3A:00:00:00 --> Dell
# C8:4B:D6:00:00:00 --> Dell
# C4:B9:CD:00:00:00 --> Cisco
# 34:98:B5:00:00:00 --> Netgear
function getCompany()
{
    local testsmac="$1"
    MacVendor=${testsmac:0:8}
    if [ "$MacVendor" == "68:5B:35" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "80:04:5F" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "90:84:0D" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "00:F7:6F" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "A4:E9:75" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "9C:35:EB" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "40:B3:95" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "F0:79:60" ] ; then echo "Apple"; return; fi
    if [ "$MacVendor" == "00:06:77" ] ; then echo "Sick AG"; return; fi
    if [ "$MacVendor" == "B8:27:EB" ] ; then echo "Raspberry Pi Foundation"; return; fi
    if [ "$MacVendor" == "48:21:0B" ] ; then echo "Intel"; return; fi
    if [ "$MacVendor" == "0a:59:50" ] ; then echo "Intel"; return; fi
    if [ "$MacVendor" == "34:60:F9" ] ; then echo "TP-Link"; return; fi
    if [ "$MacVendor" == "B4:45:06" ] ; then echo "Dell"; return; fi
    if [ "$MacVendor" == "CC:48:3A" ] ; then echo "Dell"; return; fi
    if [ "$MacVendor" == "C8:4B:D6" ] ; then echo "Dell"; return; fi
    if [ "$MacVendor" == "C4:B9:CD" ] ; then echo "Cisco"; return; fi
    if [ "$MacVendor" == "34:98:B5" ] ; then echo "Netgear"; return; fi
    # Nothing found:
    echo ""; return;
}

# #########################################
# drawUptime()
# Parameter
#    device
# Return Value
#    -
# Draw with gnuplot a diagram about the uptime of one device
#
# Outdated: We will not use gnuplot. We draw directly in html.
function drawUptime()
{
    if [ "$GnuPlotBinary" = "-" ] ; then
        #echo "[$PROG_NAME:drawUptime:WARNING] gnuplot binary not found. Can't draw uptime diagram for '$1'."
        return
    fi

    
    # Output file:
    #local DrawFile="$GraphFolder$Product"_"$OriginDate"_"$OriginTime"_"$1.png"
    #$GnuPlotBinary -e "FILENAME='$BlaBlaFile'" -e "TITLE='$1'" "$DrawScript" > "$DrawFile"
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

    local NoOwn="1"
    local MultiCast="0"
    local fileMAC=""

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
            #
            # Remove Multicast addresses from list:
            # 
            # https://de.wikipedia.org/wiki/Multicast:
            # Bei IPv4 werden die untersten 23 Bit der IP-Adresse in die MAC-Adresse 01-00-5e-00-00-00 eingesetzt, 
            # wodurch sich Adressen aus dem Bereich von 01-00-5e-00-00-00 bis 01-00-5e-7f-ff-ff ergeben können. 
            # Hierbei wird bewusst in Kauf genommen, dass mehrere IPv4-Adressen auf dieselbe MAC-Adresse abgebildet 
            # werden (zum Beispiel 224.0.0.1 und 233.128.0.1).
            # 
            MultiCast=$(isMultiCastMacAddress $newLineMAC)
            # https://www.omnisecu.com/tcpip/broadcast-mac-address.php
            # The MAC address used for broadcast (broadcast MAC address) is ff:ff:ff:ff:ff:ff. 
            # Broadcast MAC address is a MAC address consisting of all binary 1s.
            if [ "$newLineMAC" != "FF:FF:FF:FF:FF:FF" ] && [ "$MultiCast" != "1" ] ; then
                echo "$newLine"
                echo "$newLine" >> "$LinesFile"
                # We found this device. Store in database of known devices:
                # "database" is the standard data folder with filename corresponding to MAC address.
                # MAC address has form: FF:FF:FF:FF:FF:FF
                # File name has form:   FF-FF-FF-FF-FF-FF.txt
                # File contains device name from "Devices File".
                fileMAC=$(echo "$newLineMAC" | sed "s/:/-/g")
                fileMAC="device_$fileMAC.txt"
                # If Device name was unknown by a first scan, the *.txt file has size 1 and no content.
                # 
                if [ ! -e "$DataFolder$fileMAC" ] ; then
                    # New device found. Do we have a correct, means not empty, name?
                    if [ -n "$newLineName" ] ; then
                        # Name is not empty.
                        echo "$newLineName" > "$DataFolder$fileMAC"
                    fi
                else
                    # File exists but maybe is empty and we have a new non empty name.
                    if [ -n "$newLineName" ] ; then
                        local ststemp=$(cat "$DataFolder$fileMAC")
                        if [ -z "$ststemp" ] ; then
                            # Update empty name with non empty name:
                            echo "$newLineName" > "$DataFolder$fileMAC"
                        fi
                    fi
                fi
            fi
            # In der Device List taucht der localhost, also das eigene Device, nicht auf.
            if [ "$IP4ADDRESS" = "$newLineIP" ] ; then
                # We have the own IP address in the list:
                NoOwn="0"
            fi
            # Store information in relation to scan date and time:
            # csv file format:
            # 2023-01-25,14-18-00,1330,86825
        done
        
        if [ "$NoOwn" = "1" ] ; then
            # The own ip address was not part of the list. Therefore add this:
            newLineMAC="$MACADDRESS"
            newLineIP="$IP4ADDRESS"
            newLineName=$(getHostname "$newLineMAC")
            newLine="$newLineMAC;$newLineIP;$newLineName;"
            echo "$newLine"
            echo "$newLine" >> "$LinesFile"
            fileMAC=$(echo "$newLineMAC" | sed "s/:/-/g")
            fileMAC="device_$fileMAC.txt"
            if [ ! -e "$DataFolder$fileMAC" ] ; then
                # New device found. Do we have a correct, means not empty, name?
                if [ -n "$newLineName" ] ; then
                    # Name is not empty.
                    echo "$newLineName" > "$DataFolder$fileMAC"
                fi
            else
                # File exists but maybe is empty and we have a new non empty name.
                if [ -n "$newLineName" ] ; then
                    local ststemp=$(cat "$DataFolder$fileMAC")
                    if [ -z "$ststemp" ] ; then
                        # Update empty name with non empty name:
                        echo "$newLineName" > "$DataFolder$fileMAC"
                    fi
                fi
            fi
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

    # Prepare for subsequent functions, e.g. setDevicesStatus, drawDevicesStatus
    # Create list of known devices:
    # Check if there are files.
    # Background:  :> ls -1 "$DataFolder"device_*.txt"  creates an error be empty directory
    # Background:   -e  "$DataFolder"device_*.txt  generates by full directory an error of:  [: too many arguments
    #if [ -e  "$DataFolder"device_*.txt ] ; then
    if ls -A1q "$DataFolder" | grep -q . ; then
        ls -1 "$DataFolder"device_*.txt > "$KnownDevicesFile"
    else 
        echo "" > "$KnownDevicesFile"
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
    # Scan each device exactly: See listMacAddresses()
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
    # BUG TODO: Run into problems if more than one ethernet interface (e.g. LAN + WLAN) is active.
    #           "tail" included to be able to run the program. But better solution would be to
    #           scan both networks.
    # Changes: All changes done here must be also done at: devicemonitor.sh - getMacAddress()
    if [ "$GetMacApp" = "ip" ] ; then
        if [ "$SYSTEM" = "LINUX" ] ;  then
            if [ -r "/sys/class/net/eth0/address" ] ; then
                MACADDRESS=$(cat /sys/class/net/eth0/address | tr "[:lower:]" "[:upper:]" | tail -n 1)
            else
                # Try nearly similar way as on MACOSX:
                MACADDRESS=$(ip addr show | grep -i ether | sed "s/ether /;/g" | cut -d ";" -f 2 | sed "s/ /;/g" | cut -d ";" -f 1 | tr "[:lower:]" "[:upper:]" | tail -n 1)
                # E.g. output on Ubuntu from "ip addr show | grep -i ether" with one LAN and one WLAN device:
                # ip addr show | grep -i ether
                #    link/ether 1c:69:7a:66:6e:46 brd ff:ff:ff:ff:ff:ff
                #    link/ether 0c:7a:15:88:32:18 brd ff:ff:ff:ff:ff:ff
                # Alternative on ubuntu:
                # nmcli | grep -i ether | cut -d "," -f 2
                # See: https://developer-old.gnome.org/NetworkManager/stable/nmcli.html
            fi
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            MACADDRESS=$(ip -4 addr show | grep -i ether | sed "s/ether /;/g" | cut -d ";" -f 2 | tr "[:lower:]" "[:upper:]" | tail -n 1)
            # E.g. output on 23.2.0 from :
            # lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
            #	inet 127.0.0.1/8 lo0
            # en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	        #   ether 3c:22:fb:2c:cb:3f
	        #   inet 172.18.186.246/16 brd 172.18.255.255 en0
        fi
        echo "[$PROG_NAME:getOwnMacAddress:STATUS] '$MACADDRESS'"
    fi
}

# #########################################
# isMultiCastMacAddress()
# Parameter
#    1: MAC address to test
# Return Value
#    "0":  0 means no MultiCast or no MAC address
#    "1":  1 means in MultiCast range
function isMultiCastMacAddress()
{
    # https://de.wikipedia.org/wiki/Multicast:
    # Bei IPv4 werden die untersten 23 Bit der IP-Adresse in die MAC-Adresse 01-00-5e-00-00-00 eingesetzt, 
    # wodurch sich Adressen aus dem Bereich von 01-00-5e-00-00-00 bis 01-00-5e-7f-ff-ff ergeben können. 
    # Hierbei wird bewusst in Kauf genommen, dass mehrere IPv4-Adressen auf dieselbe MAC-Adresse abgebildet 
    # werden (zum Beispiel 224.0.0.1 und 233.128.0.1).

    # Check for valid length of string:
    local sLen=${#1}
    # MAC address has 17 characters:
    if [ $sLen -eq 17 ] ; then
        local subMac=${1:0:8}
        if [ "$subMac" = "01:00:5E" ] ; then
            # In MultiCast range:
            echo "1"
        else
            echo "0"
        fi
    else
        echo "0"
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
    # Note about Changes
    #
    # All changes done here must be also done at: devicemonitor.sh - getIpAddress()
    #
    # Enhancements
    #
    # Test first with :> route get 8.8.8.8 | grep -i interface | sed "s/[[:blank:]]*//g"
    # Return on MAC OS X 23.2.0: "interface:en0"
    # Take this interface for ip -4 addr show:>  ip -4 addr show en0
    # TODO: Test on other MAC an on Ubuntu and Raspi.  
    #
    if [ "$GetMacApp" = "ip" ] ; then
        #local tmpadr="0.0.0.0"
        if [ "$SYSTEM" = "LINUX" ] ;  then
            # Under "Raspbian GNU/Linux 9.13 (stretch)": Parameter -o is implemented and generates 1 line per interface:
            # If we use "head -n 1" instead of "tail -n 1" it will look for the build-in network card 
            # before looking for the USB network adapter - hopefully mostly ;-)
            IP4ADDRESS=$(ip -o -4 addr show | grep -i global | head -n 1 | sed "s/  */;/g" | cut -f 4 -d ";" | cut -f 1 -d "/")
            # IP4ADDRESS=$(ip -o -4 addr show | grep -i global | tail -n 1 | sed "s/  */;/g" | cut -f 4 -d ";" | cut -f 1 -d "/")
            #tmpadr=$(ip -o -4 addr show | grep -i global | sed "s/  */;/g")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
            #tmpadr=$(echo "$tmpadr" | cut -f 4 -d ";")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
            #tmpadr=$(echo "$tmpadr" | cut -f 1 -d "/")
            #echo "[$PROG_NAME:getOwnIpAddress:DEBUG] '$tmpadr'"
        elif [ "$SYSTEM" = "MACOSX" ] ; then
            # Under MACOSX "17.7.0": Parameter -o is not implemented
            IP4ADDRESS=$(ip -4 addr show | grep -i brd | tail -n 1 | sed "s/  */;/g" | cut -f 2 -d ";" | cut -f 1 -d "/")
        fi
        # BUG TODO
        # It is possible to have more than one networks interfaces. "tail" is a work around. 
        # Better is to scan all networks.
        # But also with 2 addresses it is possible to have no connection to the internet.
        echo "[$PROG_NAME:getOwnIpAddress:STATUS] '$IP4ADDRESS'"
        # Info
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
# setDevicesStatus()
# Parameter
#    -
# Return Value
#    -
# Set the status (reachable or not) for every known device.
# Before this function, the function listMacAddresses() must be called.
function setDevicesStatus()
{
    local searchFile=""
    local storeFile=""
    local searchMAC=""
    local isOnline=""

    # Go through each element:
    if [ -s "$KnownDevicesFile" ] ; then
        # Device exists and is not empty:
        lines=$(cat "$KnownDevicesFile")
        # Separation only by newline, not by any whitespaces (set -f turns off globbing, i.e. wildcard expansion):
        IFS='
'
        for line in $lines
        do
            # line contains the MAC address in "file name format". Therefore convert:
            searchFile=$(basename "$line")
            storeFile=$(echo "$searchFile" | sed "s/\.txt/\.csv/g")
            searchMAC=$(echo "$searchFile" | cut -d "_" -f 2 | cut -d "." -f 1 | sed "s/-/:/g")
            #echo "[$PROG_NAME:setDevicesStatus:DEBUG] MAC address: '$line' '$searchMAC' '$searchFile' '$storeFile'"
            isOnline=$(grep "$searchMAC" "$TmpDir$MacFile.ip")
            if [ -z "$isOnline" ] ; then
                #echo "[$PROG_NAME:setDevicesStatus:DEBUG] Device is offline."
                echo "$actDate,$actTime,0" >> "$DataFolder""$storeFile"
            else
                #echo "[$PROG_NAME:setDevicesStatus:DEBUG] Device is online."
                echo "$actDate,$actTime,1" >> "$DataFolder""$storeFile"
            fi
        done
        unset IFS
    else
        echo "[$PROG_NAME:setDevicesStatus:STATUS] No known devices."
    fi
}

# #########################################
# writeHtmlHead()
# Parameter:
#    1: File Name
#    2: File Title
# Write the head for a html file incl. body tag.
# Note: function from swsCosts.sh
function writeHtmlHead()
{
    echo "<!DOCTYPE html>   <html>   <head>   <meta charset=\"UTF-8\">   <title>Devices - $2</title>" > "$1"
    echo "<style>h1{font-family:sans-serif;}</style>" >> "$1"
    echo "<style>p{font-family:sans-serif;}</style>"  >> "$1"
    echo "</head><body style=\"\">" >> "$1"
}

# #########################################
# writeHtmlImage()
# Parameter:
#    1: File Name
#    2: Image Header
#    3: Image file name
# Write a body part for a html file including header and image.
# Note: function from swsCosts.sh
function writeHtmlImage()
{
    echo "<h1>$2</h1>" >> "$1"
    echo "<img src=\"https://blabla.amazonaws.com/$3\"/>" >> "$1"
}

# #########################################
# writeHtmlLink()
# Parameter:
#    1: File Name
#    2: Link Name
#    3: Link URL
# Write a body part for a html file including header and image.
function writeHtmlLink()
{
    echo "<p><a href=\"$3\"/>$2</a></p>" >> "$1"
}

# #########################################
# writeHtmlFooter()
# Parameter:
#    1: File Name
# Write the end of the body for a html file.
# Note: function from swsCosts.sh
function writeHtmlFooter()
{
    echo "</body></html>" >> "$1"
}

# #########################################
# drawDevicesStatus()
# Parameter
#    -
# Return Value
#    -
# Draw the csv values created with setDevicesStatus() with html.
# For every known device we draw an own diagram.
# Most code nearly similar to setDevicesStatus() function.
# Before this function, the function listMacAddresses() must be called.
function drawDevicesStatus()
{
    local htmlFile=""
    local searchFile=""
    local dataFile=""
    local storeFileShort=""
    local storeFile=""
    local searchMAC=""
    local deviceName=""
    local dataDate=""
    local dataTime=""
    local dataStatus=""
    local elementFirst=""
    local xArray=""
    local yArray=""

    # Go through each element:
    if [ -s "$KnownDevicesFile" ] ; then
        # Write summary html file:
        # Write the html file:
        htmlFile="$SummaryFolder""index.html"
        # TODO: Go on here...
        writeHtmlHead "$htmlFile" "Summary"
        # Device exists and is not empty:
        lines=$(cat "$KnownDevicesFile")
        # Separation only by newline, not by any whitespaces (set -f turns off globbing, i.e. wildcard expansion):
        IFS='
'
        # Iterate for every known device:
        for line in $lines
        do
            # line contains the MAC address in "file name format". Therefore convert:
            searchFile=$(basename "$line")
            # Variable "searchFile" contains e.g. value "device_00-60-B5-44-A0-D6.txt"
            # File "searchFile" contains e.g. content "Raspberry Pi"
            dataFile=$(echo "$searchFile" | sed "s/\.txt/\.csv/g")
            storeFileShort=$(echo "$searchFile" | sed "s/\.txt/\.html/g")
            storeFile="$GraphFolder""$storeFileShort"
            deviceName=$(cat "$line")
            if [ -z "$deviceName" ] ;  then
                # If we use an empty string we have nothing to click on the link in the <a> element.
                deviceName="No Name"
            fi
            searchMAC=$(echo "$searchFile" | cut -d "_" -f 2 | cut -d "." -f 1 | sed "s/-/:/g")
            #echo "[$PROG_NAME:drawDevicesStatus:DEBUG] MAC address: '$line' '$searchMAC' '$searchFile' '$storeFile' '$deviceName'"
            # Plot the file with plotly
            # https://www.w3schools.com/ai/tryit.asp?filename=tryai_plotly_scatter
            # Write html head:
            echo "<!DOCTYPE html>" > "$storeFile"
            echo "<html>
                  <script src=\"https://cdn.plot.ly/plotly-latest.min.js\"></script>
                  <body>
                  <div id=\"myPlot\" style=\"width:100%\"></div>
                  <script>" >> "$storeFile"
            # Write data points for one device into file:
            xArray=""
            yArray=""
            elementFirst="1"
            # dataFile contains the values in form: 2023-02-16,22:21:12,1
            dataLines=$(cat "$DataFolder""$dataFile")
            # Iterate for every line inside every known device:
            for dataLine in $dataLines
            do
                dataDate=$(echo "$dataLine" | cut -d "," -f 1)
                dataTime=$(echo "$dataLine" | cut -d "," -f 2)
                dataStatus=$(echo "$dataLine" | cut -d "," -f 3)
                if [ "$elementFirst" = "1" ] ; then
                    elementFirst="0"
                else
                    xArray="$xArray"","
                    yArray="$yArray"","
                fi
                xArray="$xArray""\"$dataDate\""
                yArray="$yArray""\"$dataStatus\""
            done
            #echo "[$PROG_NAME:drawDevicesStatus:DEBUG] xArray: '$xArray'"
            #echo "[$PROG_NAME:drawDevicesStatus:DEBUG] yArray: '$yArray'"
            echo "const xArray = [""$xArray""];" >> "$storeFile"
            echo "const yArray = [""$yArray""];" >> "$storeFile"
            # Write definition into file:
            echo "const data = [{
                  x:xArray,
                  y:yArray,
                  mode:\"markers\"
                  }];" >> "$storeFile"
            # Write layout into file:
            echo "const layout = {
                  xaxis: {range: [\"2023-01-01\", \"2023-12-31\"], title: \"Date\"},
                  yaxis: {range: [0, 1], title: \"Status\"},  
                  title: \"$deviceName\"
                  };" >> "$storeFile"
            # Write html foot:
            echo "Plotly.newPlot("myPlot", data, layout);
                  </script>
                  </body>
                  </html>" >> "$storeFile"
            # Write summary file:
            writeHtmlLink "$htmlFile" "$deviceName" "../_Graphs/$storeFileShort"
        done
        writeHtmlFooter "$htmlFile"
        unset IFS
    else
        echo "[$PROG_NAME:drawDevicesStatus:STATUS] No known devices."
    fi

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
    echo "    -c     : Prepare configuration file and distribute it to all clients"
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
scanNetwork "$IP4SUBNET" # This function creates 2 tmp files. These files are not used by listMacAddresses()

echo "[$PROG_NAME:STATUS] Get MAC addresses ..."
listMacAddresses
echo "[$PROG_NAME:STATUS] Prepare status files ..."
setDevicesStatus
drawDevicesStatus  # <-- TODO - not yet finished.

# Maybe TODO: Delete all created tmp files.
# delFile "$KnownDevicesFile" # Created in listMacAddresses()
# delFile "$TmpFile"          # Created in scanNetwork()
# delFile "$TmpDir$ScanFile"  # Created in scanNetwork()

echo "[$PROG_NAME:STATUS] Done."
