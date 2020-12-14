#!/bin/bash


PROG_NAME="Bash Utils Installer (local)"
PROG_VERSION="0.01"

echo "[$PROG_NAME:STATUS] Starting installer ..."

# Check if we are in the source directory:
SourceDir=$(dirname "$0")
InstallScript="$SourceDir/install_bashutils_local.sh"
if [ ! -f "$InstallScript" ] ; then
    echo "[$PROG_NAME:ERROR] Source directory not found. Exit."
    exit
fi

DestDir="$HOME/bin/"
if [ ! -d "$DestDir" ] ; then
    echo "[$PROG_NAME:ERROR] Destination directoy not found. Exit."
    exit
fi

TmpDir="$HOME/tmp/"
if [ ! -d "$TmpDir" ] ; then
    mkdir -p "$TmpDir"
    if [ ! -d "$TmpDir" ] ; then
        echo "[$PROG_NAME:ERROR] Can't create temporary directoy. Exit."
        exit
    fi
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

echo "[$PROG_NAME:STATUS] Done."
