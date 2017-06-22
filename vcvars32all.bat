@echo off

REM
REM appveyor installed Express/Community version of VisualStudio
REM and x86 compiler is always included...
REM

IF "%VSCOMNTOOLS%"=="" (
  ECHO "VisualStudio %VSVER% is not installed..."
  EXIT /B 2000
) ELSE (
  CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" x86
  CALL common :BUILD_ENV
)
