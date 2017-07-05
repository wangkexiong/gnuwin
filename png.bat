@ECHO off

REM
REM libpng building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET PNG_VER=1.6.29

CALL common :BUILD_CHAIN png zlib
IF NOT EXIST REBUILD-png GOTO :EOF

:PNG_BUILD
  curl -fsSL -o libpng-%PNG_VER%.tar.gz https://gigenet.dl.sourceforge.net/project/libpng/libpng16/%PNG_VER%/libpng-%PNG_VER%.tar.gz
  7z x libpng-%PNG_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD libpng-%PNG_VER%

  MD build
  PUSHD build

  cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE:STRING="Release" -DCMAKE_INSTALL_PREFIX:PATH="preinstall" ..
  nmake install

  MD %INSTALL_DIR%\bin %INSTALL_DIR%\include %INSTALL_DIR%\lib %INSTALL_DIR%\share
  XCOPY /S /Y preinstall\include %INSTALL_DIR%\include
  XCOPY /S /Y preinstall\share %INSTALL_DIR%\share

  IF /I "%LINK_TYPE%"=="static" (
    link /out:pngfix.exe CMakeFiles\pngfix.dir\contrib\tools\pngfix.c.obj libpng16_static.lib zlib1.lib
    IF EXIST pngfix.exe.manifest mt -manifest pngfix.exe.manifest -outputresource:pngfix.exe;1

    link /out:png-fix-itxt.exe CMakeFiles\png-fix-itxt.dir\contrib\tools\png-fix-itxt.c.obj libpng16_static.lib zlib1.lib
    IF EXIST png-fix-itxt.exe.manifest mt -manifest png-fix-itxt.exe.manifest -outputresource:png-fix-itxt.exe;1

    COPY /Y pngfix.exe %INSTALL_DIR%\bin
    COPY /y png-fix-itxt.exe %INSTALL_DIR%\bin
    COPY /Y preinstall\lib\libpng16_static.lib %INSTALL_DIR%\lib\libpng16.lib
  ) ELSE (
    XCOPY /S /Y preinstall\bin %INSTALL_DIR%\bin
    COPY /Y preinstall\lib\libpng16.lib %INSTALL_DIR%\lib
  )

  POPD
  CD ..
  CALL common :BUILD_PACK png-%PNG_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

