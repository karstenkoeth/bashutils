#!/bin/sh

# #########################################
#
# Overview
#
# Converts serverless handlers into normal shell files.
#
# See also sh2now.sh

# #########################################
#
# Versions
#
# 2021-04-11 0.01 kdk First Version with version information

PROG_NAME="now2sh"
PROG_VERSION="0.01"
PROG_DATE="2021-04-11"
PROG_CLASS="bashutils"
PROG_SCRIPTNAME="now2sh.sh"

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
    echo "[now2sh] Convert file '$FROM' ..."
  else
    echo "[now2sh:ERROR] File '$FROM' not found. Exit."
    exit
  fi
  TO="$2"
  if [ -f "$TO" ] ; then
    echo "[now2sh:WARNING] ... and overwrite file '$TO' ..."
  else
    echo "[now2sh] ... and create file '$TO' ..."
  fi
else
  echo "[now2sh:ERROR] Need two program parameter: intputfile and outputfile. Exit."
  exit
fi

# First line for Bash:
echo "#!/bin/bash" > "$TO"
echo "" >> "$TO"

# Copy handler:
cat  "$FROM" >> "$TO"

# Last lines for Bash to call handler:
echo "" >> "$TO"
echo "handler" >> "$TO"
echo "" >> "$TO"

echo "[now2sh] Done."
