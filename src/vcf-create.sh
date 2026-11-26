#!/bin/bash

# #########################################
#
# Overview
#
# Creates a vCard file (vcf, vCard version 3.0) from program parameters.
#
#   -v Vorname    : First name
#   -n Nachname   : Last name
#   -s Straße     : Street with house number
#   -p PLZ        : Postal code
#   -o Ort        : City
#   -e Email      : Email address
#   -f Firma      : Company
#   -F FILE       : Output file. Without -F, the vCard is written to stdout.
#
# At least a first name, a last name or a company is needed.
# All other values are optional; empty values are not written.
#
# Examples:
#
#   vcf-create.sh -v Max -n Mustermann -s "Hauptstraße 1" -p 76149 \
#                 -o Karlsruhe -e max@example.de -f "Muster GmbH" -F max.vcf
#
#   vcf-create.sh -v Max -n Mustermann -e max@example.de > max.vcf
#
# Result:
#
#   BEGIN:VCARD
#   VERSION:3.0
#   N:Mustermann;Max;;;
#   FN:Max Mustermann
#   ORG:Muster GmbH
#   ADR:;;Hauptstraße 1;Karlsruhe;;76149;
#   EMAIL;TYPE=INTERNET:max@example.de
#   END:VCARD
#
# Details:
#   - Lines end with CR LF, as required by the vCard standard (RFC 2426).
#   - Characters ',', ';' and '\' inside the values are escaped with '\'.
#   - Only a company (no first and last name): The company is used as
#     display name and macOS Contacts shows the card as company.
#   - The text is written in UTF-8.

# #########################################
#
# Versions
#
# 2026-11-26 0.01 kdk First Version from Claude
# 2026-11-26 0.02 kdk Minimal changed parameter and testing done
# 2026-11-26 0.03 kdk Minor bugs in help text changed.

PROG_NAME="vcf-create"
PROG_VERSION="0.03"
PROG_DATE="2026-11-26"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="vcf-create.sh"

# #########################################
#
# TODOs
#
# Lines longer than 75 characters are not folded (RFC 2426 recommends it,
# but all common programs read longer lines).

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

# Line end in vCard files:
CRLF=$'\r\n'

# #########################################
#
# Variables
#

vorname=""
nachname=""
strasse=""
plz=""
ort=""
email=""
firma=""

# Name of the vcf file (empty = stdout):
OUTPUT_FILE=""

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
    echo "    -v Vorname  : First name"
    echo "    -n Nachname : Last name"
    echo "    -s Straße   : Street with house number"
    echo "    -p PLZ      : Postal code"
    echo "    -o Ort      : City"
    echo "    -e Email    : Email address"
    echo "    -f Firma    : Company"
    echo "    -F FILE     : Output file (without -F: vCard to stdout)"
    echo "    -V          : Show Program Version"
    echo "    -h          : Show this help"
    echo "At least -v, -n or -f is needed."
    echo "Example:"
    echo "    $PROG_SCRIPTNAME -v Max -n Mustermann -s \"Hauptstraße 1\" -p 76149 -o Karlsruhe -e max@example.de -F max.vcf"
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
# Without output file the message goes to stderr, because stdout is
# reserved for the vCard.
function echoMessage()
{
    if [ -z "$OUTPUT_FILE" ] ; then
        echo "$1" >&2
    else
        echo "$1"
    fi
}

# #########################################
# escapeValue()
# Parameter
#    1: value
# Return Value
#    Value with escaped '\', ',' and ';' (via echo)
function escapeValue()
{
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//,/\\,}"
    value="${value//;/\\;}"
    echo "$value"
}

# #########################################
# writeVcard()
# Parameter
#    -
# Return Value
#    -
# Write the vCard to stdout.
function writeVcard()
{
    local fullName
    local eVorname
    local eNachname

    eVorname=$(escapeValue "$vorname")
    eNachname=$(escapeValue "$nachname")

    # Display name: "Vorname Nachname", or the company if there is no name:
    fullName="$vorname $nachname"
    fullName="${fullName# }"
    fullName="${fullName% }"
    if [ -z "$fullName" ] ; then
        fullName="$firma"
    fi

    printf '%s' "BEGIN:VCARD$CRLF"
    printf '%s' "VERSION:3.0$CRLF"
    printf '%s' "N:$eNachname;$eVorname;;;$CRLF"
    printf '%s' "FN:$(escapeValue "$fullName")$CRLF"
    if [ -n "$firma" ] ; then
        printf '%s' "ORG:$(escapeValue "$firma")$CRLF"
        if [ -z "$vorname" ] && [ -z "$nachname" ] ; then
            # macOS Contacts: show the card as company:
            printf '%s' "X-ABShowAs:COMPANY$CRLF"
        fi
    fi
    if [ -n "$strasse" ] || [ -n "$plz" ] || [ -n "$ort" ] ; then
        # ADR: post box;extended address;street;city;region;postal code;country
        printf '%s' "ADR:;;$(escapeValue "$strasse");$(escapeValue "$ort");;$(escapeValue "$plz");$CRLF"
    fi
    if [ -n "$email" ] ; then
        printf '%s' "EMAIL;TYPE=INTERNET:$(escapeValue "$email")$CRLF"
    fi
    printf '%s' "END:VCARD$CRLF"
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
        -v|-n|-s|-p|-o|-e|-f|-F)
            if [ $# -lt 2 ] ; then
                echo "[$PROG_NAME:ERROR] Missing value for $1. Use -h for help. Exit." >&2 ; exit 1
            fi
            case "$1" in
                -v) vorname="$2" ;;
                -n) nachname="$2" ;;
                -s) strasse="$2" ;;
                -p) plz="$2" ;;
                -o) ort="$2" ;;
                -e) email="$2" ;;
                -f) firma="$2" ;;
                -F) OUTPUT_FILE="$2" ;;
            esac
            shift 2
            ;;
        *)
            echo "[$PROG_NAME:ERROR] Unknown parameter '$1'. Use -h for help. Exit." >&2 ; exit 1
            ;;
    esac
done

if [ -z "$vorname" ] && [ -z "$nachname" ] && [ -z "$firma" ] ; then
    echoMessage "[$PROG_NAME:ERROR] At least -v, -n or -f is needed. Use -h for help. Exit." ; exit 1
fi

echoMessage "[$PROG_NAME:STATUS] Starting ..."

if [ -n "$OUTPUT_FILE" ] ; then
    if ! writeVcard > "$OUTPUT_FILE" ; then
        echoMessage "[$PROG_NAME:ERROR] Can't write '$OUTPUT_FILE'. Exit." ; exit 1
    fi
    echoMessage "[$PROG_NAME:STATUS] vCard written to '$OUTPUT_FILE'."
else
    writeVcard
fi

echoMessage "[$PROG_NAME:STATUS] Done."
