#!/bin/bash

# #########################################
#
# Overview
#
# Creates a markdown fragment with an image link for every file in the
# current directory whose name starts with FILE_PREFIX, followed by a date.
#
# Example: Files "Bild_2026-11-05.jpg" and "Bild_2026-11-06.png" result in:
#
#   ![2026-11-05](Bild_2026-11-05.jpg)
#   ![2026-11-06](Bild_2026-11-06.png)
#
# The link text is the part of the file name between FILE_PREFIX and the
# file extension (normally the date).
# Files are searched with 'ls' and listed in the order 'ls' returns them.
# The fragment is written to OUTPUT_FILE in the current directory.
# An existing OUTPUT_FILE is overwritten.

# #########################################
#
# Versions
#
# 2026-11-06 0.01 kdk First Version from Claude
# 2026-11-06 0.02 kdk Add program parameters -V and -h
# 2026-11-07 0.03 kdk Add support for mp4 files (only a text link, no image link)

PROG_NAME="ls2md"
PROG_VERSION="0.03"
PROG_DATE="2026-11-07"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="ls2md.sh"

# #########################################
#
# TODOs
#
# Maybe: Directory and file prefix as optional program parameters.

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2026 Karsten Köth
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

# Beginning of the file names to search for:
FILE_PREFIX="PowerBank_Personen_"

# Name of the markdown file to create (in the current directory):
OUTPUT_FILE="${FILE_PREFIX%[_-]}.md"

# #########################################
#
# Variables
#

# Number of image links written:
countFiles=0

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
    echo "Without parameter: Search in the current directory for files"
    echo "starting with '$FILE_PREFIX' and write image links to '$OUTPUT_FILE'."
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
# writeLink()
# Parameter
#    1: file name
# Return Value
#    -
# Write one markdown image link for the given file to OUTPUT_FILE.
function writeLink()
{
    local fileName="$1"
    local linkText="${fileName#"$FILE_PREFIX"}"   # remove prefix
    linkText="${linkText%.*}"                     # remove extension
    local extension="${fileName##*.}"

    if [ "$extension" = "jpg" ] || [ "$extension" = "png" ] || [ "$extension" = "jpeg" ] ; then
        echo "![$linkText]($fileName)" >> "$OUTPUT_FILE"
        countFiles=$((countFiles + 1))
    elif [ "$extension" = "mp4" ] ; then
        echo "[$linkText  -  $fileName -  Movie]: #" >> "$OUTPUT_FILE"
        # From every Movie File we generate a correspondingpicture file.
        #countFiles=$((countFiles + 1))
    else
        echo "[$PROG_NAME:WARNING] File '$fileName' isn't a supported image format '$extension'."
    fi
}

# #########################################
#
# Main
#

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ "$1" = "-V" ] ; then
        showVersion ; exit 0
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit 0
    else
        echo "[$PROG_NAME:ERROR] Unknown parameter '$1'. Use -h for help. Exit." ; exit 1
    fi
elif [ $# -gt 1 ] ; then
    echo "[$PROG_NAME:ERROR] Too many parameters. Use -h for help. Exit." ; exit 1
fi

echo "[$PROG_NAME:STATUS] Starting ..."

# Start with an empty output file:
: > "$OUTPUT_FILE"

# Search for the files with 'ls'. One file per line, also with blanks in the name:
while IFS= read -r fileName ; do
    # Only regular files, not the output file itself:
    if [ -f "$fileName" ] && [ "$fileName" != "$OUTPUT_FILE" ] ; then
        writeLink "$fileName"
    fi
done < <(ls -1 -d -- "$FILE_PREFIX"* 2> /dev/null)

if [ "$countFiles" -eq 0 ] ; then
    echo "[$PROG_NAME:WARNING] No files starting with '$FILE_PREFIX' found."
fi

echo "[$PROG_NAME:STATUS] $countFiles image links written to '$OUTPUT_FILE'."
echo "[$PROG_NAME:STATUS] Done."
