#!/bin/bash

# #########################################
#
# ########### Overview ###########
#
# This bash script permanently looks for commands inside a special directory and executes these.
# This script could be started somewhere, but the main folder is always the same. Only one
# instance of the script is able to run at the same time.
#
# ########### Folder structure ###########
#
# _Control
#    In this folder, some files show the status of the program and control the program
#
# _Execute
#    Programs mentioned in this folder will be executed. Mentioned means:
#    A file with same name as the programs executable file name but with file
#    length zero is placed in this folder.
#    At the moment (0.07) only shell scripts are supported, see function checkForExecution().
#    The program executable (or the script) is installed in the $PATH. 
#    We check this with "which program".
#    If a process terminates but the program is listed inside this folder, the process will
#    be started again.
#
# ########### Installer ###########
#
# The installer runs as an own process to be able to be restarted by this executer.
#
# _Install
#    Typically, this folder is empty. If inside the folder a file with 
#    execution rights will be found 
#    (typically a file and a subfolder was
#    copied into to folder. After having finished the copy process, the
#    installer will be changed with 'chmod u+x')
#    the file would be executed.
#
# _Done
#    If an installer was executed, it will be moved into this folder and 
#    the filename will be enhanced with Date and Time

# #########################################
#
# Versions
#
# 2021-01-29 0.01 kdk First Version - not tested and not started with main function.
# 2022-01-31 0.02 kdk TODOs added
# 2022-02-04 0.03 kdk Cleaned up
# 2022-04-19 0.04 kdk Executer for loop added
# 2022-04-27 0.05 kdk checkForPresence() added, tested on MAC-OS-X
# 2022-05-18 0.06 kdk Comments added
# 2022-06-08 0.07 kdk Comments added
# 2022-07-27 0.08 kdk -P changed from ProgramFolder to ProgramName
# 2023-02-03 0.09 kdk Some " 2> /dev/zero" added

PROG_NAME="Executer"
PROG_VERSION="0.09"
PROG_DATE="2023-02-03"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="executer.sh"

# #########################################
#
# TODOs
#
# For execute Installer: before start installer do: chmod u+x installer.sh
#
# With: (which basename --> $HOME/executer/_Execute/ (Gleich wie in Funktion unten)) -P | tail -n 1 | cut -d "=" -f 2
# The folder with _Control contains RUNNING if the program should be running.

# #########################################
#
# Compatible programs and scripts
#
# Every program should be compatible which is installed normally in the path.
# The program name should not contains spaces in the name.
# At the moment (Version 0.06) no program parameters are supported. If the 
# program needs parameters, maybe the program must be wrapped by a script
# containing the parameters.
#
# To test the functionality, see the scripts:
# - exec_test_a.sh  Runs 10 seconds and exits
# - exec_test_b.sh  Runs 7 seconds and exits 
# - exec_test_l.sh  Runs in a never ending loop

# #########################################
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

product="executer"

MainLoopResponseTime="1s"
MainLoopSleepFactor="1"


# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

InstallOnly="0"

# Standard Folders and Files

MainFolder="_"
ControlFolder="_"
ExecuteFolder="_"

RunFile="_"
LogFile="_"

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

    ExecuteFolder="$MainFolder""_Execute/"
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
# checkFolders()
# Parameter
# Check, if all folders needed are present. If not, create the folders or exit.
# With this function, we do our install at the first start ;-)
function checkFolders()
{
    checkOrCreateFolder "$MainFolder" "Main Program"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create main folder. Exit"; exit; fi
    checkOrCreateFolder "$ControlFolder" "Control"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create control folder. Exit"; exit; fi
    checkOrCreateFolder "$ExecuteFolder" "Execute"
        if [ $? -eq 1 ] ; then echo "[$PROG_NAME:ERROR] Can't create execute folder. Exit"; exit; fi
}

# #########################################
# checkForPresence()
# Parameter
#   1) executable name, e.g. ping
# Return
#   0 : ok
#   1 : not found
#   2 : not executable
# This function checks, if a program is present and executable
function checkForPresence()
{
    local sTmp
    sTmp=$(which "$1" 2> /dev/zero)
    if [ -z "$sTmp" ] ; then
        echo "[$PROG_NAME:WARNING] Program '$sTmp' not found."
        return 1
    else
        if [ -x "$sTmp" ] ; then
            #echo "[$PROG_NAME:DEBUG] Program '$sTmp' is executable."
            return 0
        else
            echo "[$PROG_NAME:WARNING] Program '$sTmp' found but not executable."
            return 2
        fi
    fi
}

# #########################################
# checkForRunning()
# Parameter
#   1) executable name, e.g. ping
# Return
#   0 : ok = is running
#   1 : error
# This function checks, if a specific program is running at the moment
function checkForRunning()
{
    local sTmp
    sTmp=$(ps xo command | grep "$1" | sed '/^grep/d')
    if [ -z "$sTmp" ] ; then
        #echo "[$PROG_NAME:DEBUG] program '$1' down"
        return 1
    else
        #echo "[$PROG_NAME:DEBUG] program '$1' is running"
        return 0
    fi
}

# #########################################
# checkForExecution()
# Parameter
# This is the real main function: It look for tasks and executes other programs.
# TODO
function checkForExecution()
{
    # For every file in ExecuteFolder:
    #   Check if the file is valid and executable
    #   Check if the process from this file is running
    
    # Normally, it is save to go with a file to support file names with spaces inside the name.
    # But here, we only care about program executables and shell scripts, 
    # these we write without spaces in the name.
    # ls -1 $SourceDir/*.sh > "$TmpFile"
    lines=$(ls -1 $ExecuteFolder*.sh)

    for line in $lines
    do
        pureLine=$(basename "$line")
        case $pureLine in 
            "$PROG_SCRIPTNAME")
                #echo "[$PROG_NAME:DEBUG] Own program '$pureLine'"
            ;;
            *)
                #echo "[$PROG_NAME:DEBUG] Program     '$pureLine'"
                checkForPresence "$pureLine"
                if [ $? -eq 0 ] ; then 
                    # find in ps ...
                    checkForRunning "$pureLine"
                    if [ $? -gt 0 ] ; then 
                        #echo "[$PROG_NAME:DEBUG] Try to restart program '$pureLine' ..."
                        "$pureLine" & 
                    fi
                fi

            ;;
        esac
    done
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

# #########################################
# removeRun()
# Parameter
# Removes the RunFile to show the program has finished.
function removeRun()
{
    delFile "$RunFile"
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
    echo "    -c     : Create only the necessary folder structure"
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
    if [ "$1"  = "-c" ] ; then
        InstallOnly="1"
    elif [ "$1" = "-P" ] ; then
        echo "ProgramName=$product" ; exit;
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:WARNING] Unknown program parameter." ;
    fi
fi

# Initialize ...
adjustVariables
checkFolders
checkStart
touch "$ExecuteFolder$PROG_SCRIPTNAME" # Minimum this script itself should run.

if [ "$InstallOnly" = "1" ] ; then
    echo "[$PROG_NAME:STATUS] Done."
    exit
fi

updateRun

echo "[$PROG_NAME:STATUS] Enter main loop. Monitor script with ':> ls --full-time $LogFile'. Stop script by deleting '$RunFile'."

# Start main loop

while [ -f "$RunFile" ]
do
    updateLog
    checkForExecution
    updateLog
    checkExit
done

# Done - clean up ...
removeRun

echo "[$PROG_NAME:STATUS] Done."
