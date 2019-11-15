#!/bin/sh
#
# Generates the documentation for gScripted using a posix system.
#
lua luadoc_start.lua *.luadoc ../installer/windows/support/scripts/*.lua --nofiles
