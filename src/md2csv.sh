#!/bin/bash

# #########################################
#
# Overview
#
# Reads a markdown file, searches the first table inside and converts this
# table into a csv file with ';' as separator.
#
# The markdown file can be given in two ways:
#
# 1. As program parameter:
#        md2csv.sh Rechnung.md
#    The csv file is written next to the markdown file. The file name is the
#    markdown file name without the ending '.md', followed by '_', the actual
#    date and time and the ending '.csv', e.g.:
#        Rechnung_2026-11-16_21-30-00.csv
#
# 2. Via stdin:
#        cat Rechnung.md | md2csv.sh > Rechnung.csv
#    The csv content is written to stdout. All status messages are written
#    to stderr, so stdout contains only the csv content.
#
# The line below the header line (with the alignment information like
# '---', ':---', '---:' or ':---:') is not written to the csv file.
# Markdown formatting is removed from the cells:
#   **bold**, __bold__, *italic*, _italic_, ~~strike~~, `code`, [Link](url)
# Leading and trailing blanks of every cell are removed.
# Tables inside code blocks (``` or ~~~) are ignored.
#
# Example:
#
#   Datum | Firma | Betrag in €
#    --- | --- | ---:
#   2026-11-16 | BlaBlub | 1.996,00
#    | **Gesamtbetrag** | **1.996,00**
#
# becomes:
#
#   Datum;Firma;Betrag in €
#   2026-11-16;BlaBlub;1.996,00
#   ;Gesamtbetrag;1.996,00

# #########################################
#
# Versions
#
# 2026-11-16 0.01 kdk First Version from Claude
# 2026-11-16 0.02 kdk Minimal testing done

PROG_NAME="md2csv"
PROG_VERSION="0.02"
PROG_DATE="2026-11-16"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="md2csv.sh"

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

# Separator in the csv file:
CSV_SEPARATOR=";"

# Regular expression for the line below the header line,
# e.g. "--- | :--- | ---: | :---:" with or without leading and trailing '|':
SEPARATOR_REGEX='^[[:space:]]*\|?[[:space:]]*:?-+:?[[:space:]]*(\|[[:space:]]*:?-+:?[[:space:]]*)*\|?[[:space:]]*$'

# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d_%H-%M-%S")

# 1 = markdown comes via stdin, csv goes to stdout:
useStdin=0

# Name of the markdown file (only if given as program parameter):
INPUT_FILE=""

# Name of the csv file (only if the markdown file is given as program parameter):
OUTPUT_FILE=""

# 1 = the header line of the table starts with '|', so every row starts with '|':
leadingPipe=0

# Number of csv lines written:
countLines=0

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
    echo "    FILE.md : Convert the first table in FILE.md to FILE_<date>_<time>.csv"
    echo "    -V      : Show Program Version"
    echo "    -h      : Show this help"
    echo "Without a file name, the markdown is read from stdin and the csv is written to stdout:"
    echo "    cat FILE.md | $PROG_SCRIPTNAME > FILE.csv"
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
# echoMessage()
# Parameter
#    1: message text
# Return Value
#    -
# Write a status, warning or error message.
# In stdin mode the message goes to stderr, because stdout is reserved for
# the csv content.
function echoMessage()
{
    if [ "$useStdin" -eq 1 ] ; then
        echo "$1" >&2
    else
        echo "$1"
    fi
}

# #########################################
# trimString()
# Parameter
#    1: string
# Return Value
#    String without leading and trailing blanks (via echo)
function trimString()
{
    local text="$1"
    text="${text#"${text%%[![:space:]]*}"}"   # remove leading blanks
    text="${text%"${text##*[![:space:]]}"}"   # remove trailing blanks
    echo "$text"
}

# #########################################
# removeFormatting()
# Parameter
#    1: string with markdown formatting
# Return Value
#    String without markdown formatting (via echo)
# Removes:
#    **bold**  __bold__  *italic*  _italic_  ~~strike~~  `code`
#    [Link text](url)  ->  Link text
# Single '*' or '_' without partner (e.g. 'file_name') are kept.
function removeFormatting()
{
    echo "$1" | sed -E \
        -e 's/\[([^]]*)\]\([^)]*\)/\1/g' \
        -e 's/\*\*([^*]+)\*\*/\1/g' \
        -e 's/__([^_]+)__/\1/g' \
        -e 's/~~([^~]+)~~/\1/g' \
        -e 's/`([^`]+)`/\1/g' \
        -e 's/\*([^*]+)\*/\1/g' \
        -e 's/(^|[^[:alnum:]])_([^_]+)_([^[:alnum:]]|$)/\1\2\3/g'
}

# #########################################
# convertRow()
# Parameter
#    1: one table row from the markdown file
# Return Value
#    One csv line (via echo)
# Splits the markdown table row at '|' and joins the cells with CSV_SEPARATOR.
# An escaped pipe '\|' inside a cell is kept as '|'.
# If a cell contains CSV_SEPARATOR or '"', the cell is put into '"'.
function convertRow()
{
    local row="$1"
    local cell
    local csvLine=""
    local first=1
    local cells=()

    # Protect escaped pipes:
    row="${row//\\|/$'\x01'}"

    row=$(trimString "$row")

    row=$(removeFormatting "$row")

    # Remove leading pipe, if the table uses leading pipes:
    if [ "$leadingPipe" -eq 1 ] ; then
        row="${row#|}"
    fi

    # Remove trailing pipe:
    row="${row%|}"

    IFS='|' read -r -a cells <<< "$row"

    # 'read' drops a last empty cell. A row ending with '| ' keeps it this way:
    if [ "${row: -1}" = "|" ] ; then
        cells+=("")
    fi

    for cell in "${cells[@]}" ; do
        cell=$(trimString "$cell")
        cell="${cell//$'\x01'/|}"        # restore escaped pipes
        if [[ "$cell" == *"$CSV_SEPARATOR"* ]] || [[ "$cell" == *\"* ]] ; then
            cell="\"${cell//\"/\"\"}\""
        fi
        if [ "$first" -eq 1 ] ; then
            csvLine="$cell"
            first=0
        else
            csvLine="$csvLine$CSV_SEPARATOR$cell"
        fi
    done

    echo "$csvLine"
}

# #########################################
# convertTable()
# Parameter
#    -
# Return Value
#    0 = table found, 1 = no table found
# Reads the markdown from stdin and writes the first table as csv to stdout.
function convertTable()
{
    local line
    local previousLine=""
    local previousHasPipe=0
    local inCodeBlock=0
    local inTable=0

    while IFS= read -r line || [ -n "$line" ] ; do
        line="${line%$'\r'}"   # Windows line endings

        if [ "$inTable" -eq 1 ] ; then
            # The table ends with the first line without '|':
            if [[ "$line" != *"|"* ]] ; then
                break
            fi
            convertRow "$line"
            countLines=$((countLines + 1))
            continue
        fi

        # Ignore code blocks:
        if [[ "$line" =~ ^[[:space:]]*(\`\`\`|~~~) ]] ; then
            if [ "$inCodeBlock" -eq 1 ] ; then
                inCodeBlock=0
            else
                inCodeBlock=1
            fi
            previousHasPipe=0
            continue
        fi
        if [ "$inCodeBlock" -eq 1 ] ; then
            continue
        fi

        # Table start: header line with '|' followed by the alignment line:
        if [ "$previousHasPipe" -eq 1 ] && [[ "$line" =~ $SEPARATOR_REGEX ]] ; then
            if [[ "$(trimString "$previousLine")" == "|"* ]] ; then
                leadingPipe=1
            fi
            convertRow "$previousLine"
            countLines=$((countLines + 1))
            inTable=1
            continue
        fi

        previousLine="$line"
        if [[ "$line" == *"|"* ]] ; then
            previousHasPipe=1
        else
            previousHasPipe=0
        fi
    done

    if [ "$inTable" -eq 1 ] ; then
        return 0
    fi
    return 1
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
    elif [ -f "$1" ] ; then
        INPUT_FILE="$1"
    else
        echo "[$PROG_NAME:ERROR] Input file '$1' not found. Use -h for help. Exit." ; exit 1
    fi
elif [ $# -eq 0 ] ; then
    if [ -t 0 ] ; then
        echo "[$PROG_NAME:ERROR] No input file and no data via stdin. Use -h for help. Exit." ; exit 1
    fi
    useStdin=1
else
    echo "[$PROG_NAME:ERROR] Program needs one input file or data via stdin. Use -h for help. Exit." ; exit 1
fi

echoMessage "[$PROG_NAME:STATUS] Starting ..."

if [ "$useStdin" -eq 1 ] ; then
    if ! convertTable ; then
        echoMessage "[$PROG_NAME:ERROR] No table found. Exit." ; exit 1
    fi
else
    OUTPUT_FILE="${INPUT_FILE%.md}_$actDateTime.csv"
    if ! convertTable < "$INPUT_FILE" > "$OUTPUT_FILE" ; then
        rm -f "$OUTPUT_FILE"
        echoMessage "[$PROG_NAME:ERROR] No table found in '$INPUT_FILE'. Exit." ; exit 1
    fi
    echoMessage "[$PROG_NAME:STATUS] Table written to '$OUTPUT_FILE'."
fi

echoMessage "[$PROG_NAME:STATUS] Done."
