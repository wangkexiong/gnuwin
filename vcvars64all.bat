@echo off

REM
REM https://www.appveyor.com/docs/build-environment/#pre-installed-software
REM appveyor installed VS2008/VS2010/VS2012 EXPRESS version,
REM which does not include 64bits compiler.
REM
REM Currently, we use SDK binding x64 compiler.
REM But should consider using build tools which without studio IDE but only compiler.
REM
REM From VS2013, appveyor provides the community version.
REM

IF "%VSVER%"=="9"  GOTO VC9BUILDTOOLS
IF "%VSVER%"=="10" GOTO SDKx64
IF "%VSVER%"=="11" GOTO SDKx64

ECHO "Try using VisualStudio Community VERSION ..."
GOTO COMMUNITY

:VC9BUILDTOOLS
  ECHO "Try using VC9BuildTools amd64 compilers ..."
  CALL "C:\vc9.buildtools\vcvarsall.bat" amd64
  GOTO :GNULIBS

:SDKx64
  ECHO "Try using WINSDK7.1 binding x64 compilers ..."
  CALL "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /Release /x64
  GOTO :GNULIBS

:COMMUNITY
  IF "%VSCOMNTOOLS%"=="" (
    ECHO "VisualStudio %VSVER% is not installed..."
    EXIT /B 2000
  ) ELSE (
    CALL "%VSCOMNTOOLS%..\..\VC\vcvarsall.bat" amd64
    GOTO :GNULIBS
  )

:GNULIBS
  CALL common :BUILD_ENV
  GOTO :EOF
