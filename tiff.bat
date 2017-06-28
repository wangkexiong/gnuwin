@ECHO off

REM
REM libtiff building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET TIFF_VER=4.0.8

CALL common :BUILD_CHAIN tiff jpeg zlib jbig
IF NOT EXIST REBUILD-tiff GOTO :EOF

:TIFF_BUILD
  curl -fsSL -o tiff-%TIFF_VER%.tar.gz http://download.osgeo.org/libtiff/tiff-%TIFF_VER%.tar.gz
  7z x tiff-%TIFF_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD tiff-%TIFF_VER%

  IF /I "%LINK_TYPE%"=="static" (
    cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%INSTALL_DIR%" -DBUILD_SHARED_LIBS:BOOL="0" -DCMAKE_BUILD_TYPE:STRING="Release" .
  ) ELSE (
    cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%INSTALL_DIR%" -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_BUILD_TYPE:STRING="Release" . 
  )

  nmake install

  CD ..
  CALL common :BUILD_PACK tiff-%TIFF_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

