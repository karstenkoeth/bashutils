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
#    In this folder, some files show the status of the program an control the program
#
# _Execute
#    Programs mentioned in this folder will be executed.
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

PROG_NAME="Executer"
PROG_VERSION="0.04"
PROG_DATE="2022-04-19"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="executer.sh"

# #########################################
#
# TODOs
#
# Write it and test it.
#
# For execute Installer: before start installer do: chmod u+x installer.sh

# #########################################
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
                echo "[$PROG_NAME:STATUS] Own program '$pureLine'"
            ;;
            *)
                echo "[$PROG_NAME:STATUS] Program     '$pureLine'"
                # TODO: Was soll nun passieren?
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
    else
        echo "[$PROG_NAME:WARNING] Unknown program parameter." ;
    fi
fi

# Initialize ...
adjustVariables
checkFolders
checkStart
touch "$ExecuteFolder$PROG_SCRIPTNAME" # Minimum this script itself should run.
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
