# #########################################
#
# Overview
#
# This is an bash script include file.
# This file is used by:
#  - image_viewer_server.sh as image_viewer_common_func.bash
#  - html_collect_pictures.sh as image_viewer_common_func.bash
#  - bash-script-template.sh as bashutils_common_functions.bash

# #########################################
#
# Versions
#
# 2018-04-06 0.01 kdk First version
# 2018-05-21 0.10 kdk With license text.
# 2020-12-17 0.20 kdk Renamed from image_viewer_common_func.bash to bashutils_common_functions.bash
# 2020-12-20 0.21 kdk With is Number from http-echo.sh

# #########################################
#
# MIT license (MIT)
#
# Copyright 2020 Karsten Köth
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
# Functions
#

# #########################################
# echod
# Shows debug messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echod()
{
  if [ "$ECHODEBUG" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echov
# Shows verbose messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echov()
{
  if [ "$ECHOVERBOSE" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echon
# Shows normal messages. Could be switched off with e.g. "-q" = "--quiet"
# Parameters:
# $1 : Function calling
# $2 : Content
function echon()
{
  if [ "$ECHONORMAL" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echow
# Shows warning messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echow()
{
  if [ "$ECHOWARNING" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echoe
# Shows error messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echoe()
{
  if [ "$ECHOERROR" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}


# #########################################
# isNumber()
# Parameter
#  1  : String to check
# Return Value
#  1  : 0 = is number
# Check, if the string contains only digits.
function isNumber()
{
case $1 in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
esac
}
