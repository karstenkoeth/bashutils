#!/bin/bash

# #########################################
#
# Overview
#
# Calculates the sum of one column of a csv file.
# The program parameters are similar to 'cut':
#
#   -f FIELD : Number of the column to sum up (first column = 1)
#   -d DELIM : Separator of the csv file (default: ';')
#   -t       : Write the sum with thousands separator '.'
#
# The csv file can be given in two ways:
#
# 1. As last program parameter:
#        csv-calc-sum.sh -f 4 Rechnung.csv
# 2. Via stdin:
#        cat Rechnung.csv | csv-calc-sum.sh -f 4
#
# The sum is written to stdout. All status messages are written to stderr,
# so the sum can be used directly in other scripts:
#        summe=$(csv-calc-sum.sh -f 4 Rechnung.csv)
#
# Numbers are in German format:
#   - ',' is the decimal separator:            35,23
#   - '.' is the (optional) thousands separator: 1.996,00 or 1996,00
#   - Leading '+' or '-' is allowed:            -12,5
#   - Cells in '"' are allowed:                 "1.996,00"
#   - Markdown bold markers are removed:        **1.996,00**
# Cells which are not a number (e.g. the header line) or which are empty
# are ignored. The number of ignored lines is shown as status message.
#
# The sum is calculated exactly (integer arithmetic, no rounding errors).
# The sum has as many decimal places as the number with the most decimal
# places in the column.
#
# Example:
#
#   Datum;Firma;Betrag in €
#   2026-11-16;BlaBlub;1.996,00
#   2026-11-16;BlaBlub;1.896,20
#
#   csv-calc-sum.sh -f 3 Rechnung.csv     ->  3892,20
#   csv-calc-sum.sh -t -f 3 Rechnung.csv  ->  3.892,20

# #########################################
#
# Versions
#
# 2026-11-16 0.01 kdk First Version from Claude
# 2026-11-16 0.02 kdk Minimal testing done

PROG_NAME="csv-calc-sum"
PROG_VERSION="0.02"
PROG_DATE="2026-11-16"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="csv-calc-sum.sh"

# #########################################
#
# TODOs
#
# Separators inside of '"' are not supported (same as 'cut').

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

# Regular expression for a number in German format:
# optional sign, digits with or without '.' as thousands separator,
# optional ',' with decimal places.
NUMBER_REGEX='^[+-]?([0-9]{1,3}(\.[0-9]{3})+|[0-9]+)(,[0-9]+)?$'

# #########################################
#
# Variables
#

# Separator of the csv file:
csvSeparator=";"

# Column to sum up (first column = 1):
field=""

# 1 = write the sum with thousands separator:
thousandsSeparator=0

# Name of the csv file (empty = stdin):
INPUT_FILE=""

# All numbers found, without thousands separator, e.g. "-1996,5":
numbers=()

# Maximum number of decimal places of all numbers:
maxDecimals=0

# Number of lines without a number in the column:
countIgnored=0

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
    echo "    -f FIELD : Number of the column to sum up (first column = 1, mandatory)"
    echo "    -d DELIM : Separator of the csv file (default: '$csvSeparator')"
    echo "    -t       : Write the sum with thousands separator '.'"
    echo "    -V       : Show Program Version"
    echo "    -h       : Show this help"
    echo "    FILE     : csv file as last parameter. Without FILE, the csv is read from stdin."
    echo "Numbers in German format: ',' as decimal separator, '.' as optional thousands separator."
    echo "Examples:"
    echo "    $PROG_SCRIPTNAME -f 4 Rechnung.csv"
    echo "    cat Rechnung.csv | $PROG_SCRIPTNAME -t -d ',' -f 2"
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
# Write a status, warning or error message to stderr, because stdout is
# reserved for the sum.
function echoMessage()
{
    echo "$1" >&2
}

# #########################################
# readNumbers()
# Parameter
#    -
# Return Value
#    -
# Reads the csv from stdin, takes the cell of column 'field' from every line
# and stores every valid number in 'numbers'.
function readNumbers()
{
    local line
    local cell
    local decimals
    local rest
    local i

    while IFS= read -r line || [ -n "$line" ] ; do
        line="${line%$'\r'}"   # Windows line endings

        # Take the cell of column 'field'. No 'read -a', because with a
        # tabulator as separator 'read' would merge empty cells:
        rest="$line$csvSeparator"
        for (( i = 1 ; i < field ; i++ )) ; do
            if [[ "$rest" != *"$csvSeparator"* ]] ; then
                rest=""
                break
            fi
            rest="${rest#*"$csvSeparator"}"
        done
        cell="${rest%%"$csvSeparator"*}"

        cell="${cell//[[:space:]]/}"   # remove blanks
        cell="${cell//\*\*/}"          # remove markdown bold markers
        cell="${cell#\"}"              # remove '"' around the cell
        cell="${cell%\"}"

        if [[ "$cell" =~ $NUMBER_REGEX ]] ; then
            cell="${cell//./}"         # remove thousands separators
            if [[ "$cell" == *","* ]] ; then
                decimals="${cell#*,}"
                if [ "${#decimals}" -gt "$maxDecimals" ] ; then
                    maxDecimals="${#decimals}"
                fi
            fi
            numbers+=("$cell")
        else
            countIgnored=$((countIgnored + 1))
        fi
    done
}

# #########################################
# toInteger()
# Parameter
#    1: number without thousands separator, e.g. "-1996,5"
# Return Value
#    Number multiplied with 10^maxDecimals as integer (via echo), e.g. "-199650"
function toInteger()
{
    local number="$1"
    local sign=""
    local integerPart
    local decimalPart=""

    if [[ "$number" == -* ]] ; then
        sign="-"
    fi
    number="${number#[+-]}"

    integerPart="${number%%,*}"
    if [[ "$number" == *","* ]] ; then
        decimalPart="${number#*,}"
    fi

    # Fill up the decimal places with '0':
    while [ "${#decimalPart}" -lt "$maxDecimals" ] ; do
        decimalPart="${decimalPart}0"
    done

    # '10#' prevents the interpretation of leading zeros as octal number:
    echo "$sign$((10#$integerPart$decimalPart))"
}

# #########################################
# formatSum()
# Parameter
#    1: sum as integer, multiplied with 10^maxDecimals
# Return Value
#    Sum in German format (via echo), e.g. "3.892,20"
function formatSum()
{
    local sum="$1"
    local sign=""
    local integerPart
    local decimalPart=""
    local formatted=""

    if [[ "$sum" == -* ]] ; then
        sign="-"
        sum="${sum#-}"
    fi

    if [ "$maxDecimals" -gt 0 ] ; then
        # Leading zeros are needed, e.g. 5 with 2 decimal places is "0,05":
        while [ "${#sum}" -le "$maxDecimals" ] ; do
            sum="0$sum"
        done
        integerPart="${sum:0:$((${#sum} - maxDecimals))}"
        decimalPart=",${sum:$((${#sum} - maxDecimals))}"
    else
        integerPart="$sum"
    fi

    if [ "$thousandsSeparator" -eq 1 ] ; then
        while [ "${#integerPart}" -gt 3 ] ; do
            formatted=".${integerPart: -3}$formatted"
            integerPart="${integerPart:0:$((${#integerPart} - 3))}"
        done
    fi
    formatted="$integerPart$formatted"

    # No "-0,00":
    if [[ "$formatted$decimalPart" =~ ^[0.,]+$ ]] ; then
        sign=""
    fi

    echo "$sign$formatted$decimalPart"
}

# #########################################
#
# Main
#

# Check for program parameters (similar to 'cut', also "-f4" and "-d,"):
while [ $# -gt 0 ] ; do
    case "$1" in
        -V)
            showVersion ; exit 0
            ;;
        -h)
            showHelp ; exit 0
            ;;
        -t)
            thousandsSeparator=1
            shift 1
            ;;
        -d)
            if [ $# -lt 2 ] ; then
                echoMessage "[$PROG_NAME:ERROR] Missing separator for -d. Use -h for help. Exit." ; exit 1
            fi
            csvSeparator="$2"
            shift 2
            ;;
        -d?*)
            csvSeparator="${1#-d}"
            shift 1
            ;;
        -f)
            if [ $# -lt 2 ] ; then
                echoMessage "[$PROG_NAME:ERROR] Missing column for -f. Use -h for help. Exit." ; exit 1
            fi
            field="$2"
            shift 2
            ;;
        -f?*)
            field="${1#-f}"
            shift 1
            ;;
        -*)
            echoMessage "[$PROG_NAME:ERROR] Unknown parameter '$1'. Use -h for help. Exit." ; exit 1
            ;;
        *)
            if [ $# -gt 1 ] ; then
                echoMessage "[$PROG_NAME:ERROR] The csv file must be the last parameter. Use -h for help. Exit." ; exit 1
            fi
            if [ ! -f "$1" ] ; then
                echoMessage "[$PROG_NAME:ERROR] Input file '$1' not found. Exit." ; exit 1
            fi
            INPUT_FILE="$1"
            shift 1
            ;;
    esac
done

if [ -z "$field" ] ; then
    echoMessage "[$PROG_NAME:ERROR] Parameter -f is missing. Use -h for help. Exit." ; exit 1
fi
if ! [[ "$field" =~ ^[1-9][0-9]*$ ]] ; then
    echoMessage "[$PROG_NAME:ERROR] Column '$field' for -f must be one number >= 1. Exit." ; exit 1
fi
if [ "${#csvSeparator}" -ne 1 ] ; then
    echoMessage "[$PROG_NAME:ERROR] Separator for -d must be one character. Exit." ; exit 1
fi
if [ -z "$INPUT_FILE" ] && [ -t 0 ] ; then
    echoMessage "[$PROG_NAME:ERROR] No input file and no data via stdin. Use -h for help. Exit." ; exit 1
fi

echoMessage "[$PROG_NAME:STATUS] Starting ..."

if [ -n "$INPUT_FILE" ] ; then
    readNumbers < "$INPUT_FILE"
else
    readNumbers
fi

if [ "${#numbers[@]}" -eq 0 ] ; then
    echoMessage "[$PROG_NAME:ERROR] No numbers found in column $field. Exit." ; exit 1
fi

sum=0
for number in "${numbers[@]}" ; do
    sum=$((sum + $(toInteger "$number")))
done

formatSum "$sum"

echoMessage "[$PROG_NAME:STATUS] ${#numbers[@]} numbers added, $countIgnored lines ignored."
echoMessage "[$PROG_NAME:STATUS] Done."
