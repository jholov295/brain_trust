@echo off
::
:: Generates the documentation for gScripted on Windows.
::
lua luadoc_start.lua *.luadoc ..\installer\windows\support\scripts\*.lua  --nofiles
