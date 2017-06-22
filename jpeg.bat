@ECHO off

REM
REM JPEG building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET JPEG_VER=9b

CALL common :BUILD_CHAIN jpeg
IF NOT EXIST REBUILD-jpeg GOTO :EOF

:JPEG_BUILD
  curl -fsSL -o jpegsrc.v%JPEG_VER%.tar.gz http://www.ijg.org/files/jpegsrc.v%JPEG_VER%.tar.gz
  7z x jpegsrc.v%JPEG_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD jpeg-%JPEG_VER%

  patch -p1 -i ..\patches\jpeg-9b.Enable.DLL.Build.patch
  REN jconfig.vc jconfig.h

  IF /I "%LINK_TYPE%"=="static" (
    nmake /f makefile.vc nodebug=1 static=1
  ) ELSE (
    nmake /f makefile.vc nodebug=1
  )

  MD %INSTALL_DIR%\bin %INSTALL_DIR%\include %INSTALL_DIR%\lib
  COPY *.exe %INSTALL_DIR%\bin
  COPY jconfig.h %INSTALL_DIR%\include
  COPY jerror.h %INSTALL_DIR%\include
  COPY jmorecfg.h %INSTALL_DIR%\include
  COPY jpeglib.h %INSTALL_DIR%\include

  IF /I "%LINK_TYPE%"=="static" (
    COPY libjpeg.lib %INSTALL_DIR%\lib
  ) ELSE (
    COPY libjpeg.lib %INSTALL_DIR%\lib
    COPY libjpeg.dll %INSTALL_DIR%\bin
  )

  CD ..
  CALL common :BUILD_PACK jpeg-%JPEG_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

