@ECHO off

REM
REM OpenSSL building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET OPENSSL_VER=1.0.2l

CALL common :BUILD_CHAIN openssl zlib
IF NOT EXIST REBUILD-openssl GOTO :EOF

:OPENSSL_BUILD
  IF "%VCVARS_PLATFORM%"=="64" (
    SET TARGET=VC-WIN64A
    SET DO=do_win64a
  ) ELSE (
    SET TARGET=VC-WIN32
    SET DO=do_nasm
  )

  IF /I "%LINK_TYPE%"=="static" (
    SET MAK=nt.mak
  ) ELSE (
    SET MAK=ntdll.mak
  )

  curl -fsSL -o openssl-%OPENSSL_VER%.tar.gz https://www.openssl.org/source/openssl-%OPENSSL_VER%.tar.gz
  7z x openssl-%OPENSSL_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD openssl-%OPENSSL_VER%

  perl Configure %TARGET% --prefix=%INSTALL_DIR% zlib-dynamic
  CALL ms\%DO%
  nmake /f ms\%MAK% install

  CD ..
  CALL common :BUILD_PACK openssl-%OPENSSL_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

