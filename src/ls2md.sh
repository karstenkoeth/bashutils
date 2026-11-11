#!/bin/bash

# #########################################
#
# Overview
#
# Creates a markdown fragment with an image link for every file in the
# current directory whose name starts with FILE_PREFIX, followed by a date.
# FILE_PREFIX can be changed with the -p parameter.
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
# 2026-11-09 0.04 kdk Add program parameter -p to set the file prefix
# 2026-11-10 0.05 kdk Add program parameter -e to write html flexbox design
# 2026-11-11 0.06 kdk Add Location
# 2026-11-11 0.07 kdk Page Break added.

PROG_NAME="ls2md"
PROG_VERSION="0.07"
PROG_DATE="2026-11-11"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="ls2md.sh"

# #########################################
#
# TODOs
#

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

# #########################################
#
# Variables
#

# Number of image links written:
countFiles=0
enhanced=0
zweitesHalbjahr=0
year="**XXXX**"
numberPowerStations="**XXX**"

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
    echo "    -p PREFIX : Set the file prefix (default: '$FILE_PREFIX')"
    echo "    -e        : Write HTML flexbox design inside markdown"
    echo "    -2        : Set the report to the second half of the year (default: first half)"
    echo "    -n NUMBER : Set the number of power stations (default: '$numberPowerStations')"
    echo "    -y YEAR   : Set the report year (default: '$year')"
    echo "    -V        : Show Program Version"
    echo "    -h        : Show this help"
    echo "Search in the current directory for files"
    echo "starting with '$FILE_PREFIX' and write image links to '${FILE_PREFIX%[_-]}.md'."
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
# writeHeader()
# Parameter
#    -
# Return Value
#    -
# Write the header for the markdown file.
function writeHeader()
{
    echo "# Power für Kiew
## Kurzbericht zur Verteilung
<div style=\"color:#888888\">
Halbjahresbericht
</div>

" >> "$OUTPUT_FILE"

    if [ "$zweitesHalbjahr" -eq 1 ] ; then
        echo "#### Zeitraum: 2. Halbjahr $year | Region: Kiew und Umgebung" >> "$OUTPUT_FILE"
    else
        echo "#### Zeitraum: 1. Halbjahr $year | Region: Kiew und Umgebung" >> "$OUTPUT_FILE"
    fi

    echo "
Im Berichtszeitraum wurden mit Unterstützung von THAT’S WHYnheim e.V. insgesamt $numberPowerStations
Powerstations an bedürftige Familien in der Region Kiew verteilt.

Unser Ansprechpartner vor Ort ist Dima Ushatyi. Er kennt die Situation der Familien und prüft, welche
Haushalte ein Gerät benötigen und auf Unterstützung angewiesen sind. Nach Eintreffen der Geräte
übergibt er diese nach und nach persönlich an die ausgewählten Familien.

Die Familien sind für die Unterstützung sehr dankbar. Die folgenden Fotos zeigen beispielhaft die
persönlichen Übergaben im Berichtszeitraum.

<style>
.gallery {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.gallery-box {
    flex: 1 1 calc(50% - 20px);
    box-sizing: border-box;
}

.gallery-box img {
    width: 100%;
    height: auto;
    display: block;
}
</style>

<div class=\"gallery\">

" >> "$OUTPUT_FILE"

}

# #########################################
# writeFooter()
# Parameter
#    -
# Return Value
#    -
# Write the footer for the markdown file:
# First: Closes the <div class=\"gallery\"> from our flexboxes design.
# Second: Writes the total number of distributed devices and a signature line.
function writeFooter()
{
    local currentDate
    currentDate=$(date +%d.%m.%Y)
    echo "</div>

<div style=\"page-break-after: always;\"></div>

Insgesamt verteilte Geräte: $numberPowerStations </br></br></br>
Datum: $currentDate       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;       Unterschriften: ____________________________________           
<i style=\"color:white;\">Datum: $currentDate       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;       Unterschriften: </i>Sabine Köth · Karsten Köth · Power für Kiew

" >> "$OUTPUT_FILE"

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
    local textFile="${fileName%.*}.txt"
    local linkText="${fileName#"$FILE_PREFIX"}"   # remove prefix
    linkText="${linkText%.*}"                     # remove extension
    local extension="${fileName##*.}"
    local familyName="Familie"

    if [ "$extension" = "jpg" ] || [ "$extension" = "png" ] || [ "$extension" = "jpeg" ] ; then
        if [ "$enhanced" -eq 1 ] ; then
            # html image link in flexbox design:
            echo "" >> "$OUTPUT_FILE"
            echo "<div class=\"gallery-box\">" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            # Look for the name of the persons.
            if [ -f "$textFile" ]; then
                familyName=$(<"$textFile")
            fi
            echo "<h4>$familyName - Kiew</h4>" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "<img src=\"$fileName\" alt=\"$linkText\">" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "</div>" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        else
            # MarkDown image link:
            echo "![$linkText]($fileName)" >> "$OUTPUT_FILE"
        fi
        countFiles=$((countFiles + 1))
    elif [ "$extension" = "mp4" ] ; then
        echo "[$linkText  -  $fileName -  Movie]: #" >> "$OUTPUT_FILE"
        # From every Movie File we generate a correspondingpicture file.
        #countFiles=$((countFiles + 1))
    elif [ "$extension" = "txt" ] ; then
        echo "[$linkText  -  $fileName -  Text Database]: #" >> "$OUTPUT_FILE"
        # This is a text file, not an image.
    else
        echo "[$PROG_NAME:WARNING] File '$fileName' isn't a supported file format '$extension'."
    fi
}

# #########################################
#
# Main
#

# Check for program parameters:
while [ $# -gt 0 ] ; do
    case "$1" in
        -V)
            showVersion ; exit 0
            ;;
        -h)
            showHelp ; exit 0
            ;;
        -e) 
            enhanced=1 ; echo "[$PROG_NAME:STATUS] Enhanced HTML flexbox design enabled." ; 
            shift 1
            ;;
        -2)
            zweitesHalbjahr=1 ; echo "[$PROG_NAME:STATUS] Report for the second half of the year enabled." ;
            shift 1
            ;;
        -p)
            if [ $# -lt 2 ] ; then
                echo "[$PROG_NAME:ERROR] Missing prefix for -p. Use -h for help. Exit." ; exit 1
            fi
            FILE_PREFIX="$2"
            shift 2
            ;;
        -n)
            if [ $# -lt 2 ] ; then
                echo "[$PROG_NAME:ERROR] Missing number for -n. Use -h for help. Exit." ; exit 1
            fi
            numberPowerStations="$2"
            echo "[$PROG_NAME:STATUS] Number of power stations set to '$numberPowerStations'."
            shift 2
            ;;
        -y)
            if [ $# -lt 2 ] ; then
                echo "[$PROG_NAME:ERROR] Missing year for -y. Use -h for help. Exit." ; exit 1
            fi
            year="$2"
            echo "[$PROG_NAME:STATUS] Report year set to '$year'."
            shift 2
            ;;
        *)
            echo "[$PROG_NAME:ERROR] Unknown parameter '$1'. Use -h for help. Exit." ; exit 1
            ;;
    esac
done

# Name of the markdown file to create (in the current directory):
OUTPUT_FILE="${FILE_PREFIX%[_-]}.md"

echo "[$PROG_NAME:STATUS] Starting ..."

# Start with an empty output file:
: > "$OUTPUT_FILE"

if [ "$enhanced" -eq 1 ] ; then
    writeHeader
fi

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

if [ "$enhanced" -eq 1 ] ; then
    writeFooter
fi

echo "[$PROG_NAME:STATUS] $countFiles image links written to '$OUTPUT_FILE'."
echo "[$PROG_NAME:STATUS] Done."
