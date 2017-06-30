@ECHO off

REM
REM bzip2 building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET BZIP2_VER=1.0.6

CALL common :BUILD_CHAIN bzip2
IF NOT EXIST REBUILD-bzip2 GOTO :EOF

:BZIP2_BUILD
  curl -fsSL -o bzip2-%BZIP2_VER%.tar.gz http://www.bzip.org/%BZIP2_VER%/bzip2-%BZIP2_VER%.tar.gz
  7z x bzip2-%BZIP2_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD bzip2-%BZIP2_VER%

  patch -p1 -i ..\patches\bzip2-%BZIP2_VER%.Optimise.Win.Build.patch

  IF /I "%LINK_TYPE%"=="static" (
    nmake /f makefile.msc static=1
  ) ELSE (
    nmake /f makefile.msc
  )

  MD %INSTALL_DIR%\bin %INSTALL_DIR%\include %INSTALL_DIR%\lib
  COPY *.exe %INSTALL_DIR%\bin
  COPY bzlib.h %INSTALL_DIR%\include

  IF /I "%LINK_TYPE%"=="static" (
    COPY libbz2.lib %INSTALL_DIR%\lib
  ) ELSE (
    COPY libbz2_i.lib %INSTALL_DIR%\lib\libbz2.lib
    COPY libbz2.dll %INSTALL_DIR%\bin
  )

  CD ..
  CALL common :BUILD_PACK bzip2-%BZIP2_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

