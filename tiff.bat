@ECHO off

REM
REM libtiff building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET TIFF_VER=4.0.8

CALL common :BUILD_CHAIN tiff jpeg zlib
IF NOT EXIST REBUILD-tiff GOTO :EOF

:TIFF_BUILD
  curl -fsSL -o tiff-%TIFF_VER%.tar.gz http://download.osgeo.org/libtiff/tiff-%TIFF_VER%.tar.gz
  7z x tiff-%TIFF_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD tiff-%TIFF_VER%

  patch -p1 -i ..\patches\tiff-4.0.8.Optimise.Win.Build.patch

  IF /I "%LINK_TYPE%"=="static" (
    nmake /f Makefile.vc gnuwin=%INSTALL_DIR% static=1
  ) ELSE (
    nmake /f Makefile.vc gnuwin=%INSTALL_DIR%
  )

  COPY tools\*.exe %INSTALL_DIR%\bin

  COPY libtiff\tiff.h      %INSTALL_DIR%\include
  COPY libtiff\tiffconf.h  %INSTALL_DIR%\include
  COPY libtiff\tiffio.h    %INSTALL_DIR%\include
  COPY libtiff\tiffio.hxx  %INSTALL_DIR%\include
  COPY libtiff\tiffvers.h  %INSTALL_DIR%\include

  IF /I "%LINK_TYPE%"=="static" (
    COPY libtiff\libtiff.lib %INSTALL_DIR%\lib
  ) ELSE (
    COPY libtiff\libtiff_i.lib %INSTALL_DIR%\lib\libtiff.lib
    COPY libtiff\libtiff.dll %INSTALL_DIR%\bin
  )

  CD ..
  CALL common :BUILD_PACK tiff-%TIFF_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

