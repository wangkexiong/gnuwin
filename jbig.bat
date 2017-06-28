@ECHO off

REM
REM libjbig building
REM vcvarsall should be set before script running
REM default building 32bits/shared
REM

SET JBIG_VER=2.1

CALL common :BUILD_CHAIN jbig
IF NOT EXIST REBUILD-jbig GOTO :EOF

:JBIG_BUILD
  curl -fsSL -o jbigkit-%JBIG_VER%.tar.gz https://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-%JBIG_VER%.tar.gz
  7z x jbigkit-%JBIG_VER%.tar.gz -so | 7z x -si -ttar > nul
  CD jbigkit-%JBIG_VER%

  COPY /Y ..\galaxy\jbig-%JBIG_VER%\* .

  IF /I "%LINK_TYPE%"=="static" (
    nmake /f Makefile.vc static=1
  ) ELSE (
    nmake /f Makefile.vc
  )

  MD %INSTALL_DIR%\bin %INSTALL_DIR%\include %INSTALL_DIR%\lib

  COPY *.exe %INSTALL_DIR%\bin
  COPY libjbig\*.h %INSTALL_DIR%\include

  IF /I "%LINK_TYPE%"=="static" (
    COPY jbig.lib %INSTALL_DIR%\lib\libjbig.lib
    COPY jbig85.lib %INSTALL_DIR%\lib\libjbig85.lib
  ) ELSE (
    COPY libjbig.lib %INSTALL_DIR%\lib
    COPY libjbig85.lib %INSTALL_DIR%\lib
    COPY libjbig.dll %INSTALL_DIR%\bin
    COPY libjbig85.dll %INSTALL_DIR%\bin
  )

  CD ..
  CALL common :BUILD_PACK jbig-%JBIG_VER%.%VCVARS_ARCH%-%LINK_TYPE%.7z %INSTALL_DIR%

