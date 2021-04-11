#!/bin/sh

# #########################################
#
# Overview
#
# Converts normal shell files into files to use as serverless
# functions with now.sh
#
# See also now2sh.sh

# #########################################
#
# Versions
#
# 2021-04-11 0.01 kdk First Version with version information

PROG_NAME="sh2now"
PROG_VERSION="0.01"
PROG_DATE="2021-04-11"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="sh2now.sh"

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2021 Karsten Köth
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
# Main
#

# Search for program parameters:

if [ "$#" -eq 2 ] ; then
  FROM="$1"
  if [ -f "$FROM" ] ; then
    echo "[sh2now] Convert file '$FROM' ..."
  else
    echo "[sh2now:ERROR] File '$FROM' not found. Exit."
    exit
  fi
  TO="$2"
  if [ -f "$TO" ] ; then
    echo "[sh2now:WARNING] and overwrite file '$TO' ..."
  else
    echo "[sh2now] ... and create file '$TO' ..."
  fi
else
  echo "[sh2now:ERROR] Need two program parameter: intputfile and outputfile. Exit."
  exit
fi

# First line for Serverless:
echo "handler() {" > "$TO"
echo "" >> "$TO"

# Remove first line from bash file = start with second line:
tail -n "+2" "$FROM" >> "$TO"

# Last line for Serverless:
echo "}" >> "$TO"
echo "" >> "$TO"

echo "[now2sh] Done."
