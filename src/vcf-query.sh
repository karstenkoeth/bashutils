#!/bin/bash

# #########################################
#
# Overview
#
# Queries contacts from macOS Contacts application using AppleScript.
# The query in my contacts is very time consuming, over a minute.

# #########################################
#
# Versions
#
# 2026-11-27 0.01 kdk First Version from Claude with code from kdk

PROG_NAME="vcf-query"
PROG_VERSION="0.01"
PROG_DATE="2026-11-27"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="vcf-query.sh"

# #########################################
#
# Variables
#

searchstring="Max Mustermann"  # Default search string. Can be changed with -q parameter.

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
    echo "    -q string   : With this string, the contacts are searched in the macOS Contacts application."
    echo "    -V          : Show Program Version"
    echo "    -h          : Show this help"
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
while [ $# -gt 0 ] ; do
    case "$1" in
        -V)
            showVersion ; exit 0
            ;;
        -h)
            showHelp ; exit 0
            ;;
        -q)
            if [ $# -lt 2 ] ; then
                echo "[$PROG_NAME:ERROR] Missing value for $1. Use -h for help. Exit." >&2 ; exit 1
            fi
            searchstring="$2"
            shift 2
            ;;
        *)
            echo "[$PROG_NAME:ERROR] Unknown parameter '$1'. Use -h for help. Exit." >&2 ; exit 1
            ;;
    esac
done

echo "[$PROG_NAME:STATUS] Querying contacts with name containing '$searchstring'..."

osascript - "$searchstring" <<'EOF'
on run argv
    set suchbegriff to item 1 of argv
    tell application "Contacts"
        set ausgabe to ""
        repeat with p in (people whose name contains suchbegriff)
            set n to name of p
            repeat with a in addresses of p
                set s to street of a
                set z to zip of a
                set o to city of a
                set c to country of a
                if s is missing value then set s to ""
                if z is missing value then set z to ""
                if o is missing value then set o to ""
                if c is missing value then set c to ""
                set ausgabe to ausgabe & n & ";" & s & ";" & z & ";" & o & ";" & c & ";" & linefeed
            end repeat
        end repeat
        return ausgabe
    end tell
end run
EOF

echo "[$PROG_NAME:STATUS] Done."
