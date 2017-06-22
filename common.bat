@echo off

@REM
@REM Common Functions
@REM

IF "%DEFAULT_PREFIX%"=="" SET DEFAULT_PREFIX=C:\build

CALL %*
GOTO :EOF

:BUILD_ENV
  @REM ------------------------------------------------------------------{{{{
  @REM Building ENV setting for x86/amd64
  @REM And already build artifacts to be working with VC compilers...
  @REM

  IF NOT "%VCVARS_PLATFORM%"=="64" (
    SET VCVARS_PLATFORM=32
    SET VCVARS_ARCH=x86
  ) ELSE (
    SET VCVARS_ARCH=amd64
  )

  IF NOT "%LINK_TYPE%"=="static" (
    SET LINK_TYPE=shared
  )

  IF "%PREFIX%"=="" (
    SET PREFIX=%DEFAULT_PREFIX%
  )

  SET INSTALL_DIR=%PREFIX%%VCVARS_PLATFORM%
  SET INCLUDE=%INSTALL_DIR%\include;%INCLUDE%
  SET LIB=%INSTALL_DIR%\lib;%LIB%
  SET LIBPATH=%INSTALL_DIR%\lib;%LIBPATH%

  GOTO :EOF
  @REM }}}

:BUILD_CHAIN
  @REM ------------------------------------------------------------------{{{{
  @REM Build Artifacts according to its defined building chain...
  @REM

  IF "%VCVARS_PLATFORM%"=="" (
    SET VCVARS_PLATFORM=32
    SET VCVARS_ARCH=x86
  )

  IF "%LINK_TYPE%"=="" (
    SET LINK_TYPE=shared
  )

  IF "%PREFIX%"=="" (
    SET PREFIX=%DEFAULT_PREFIX%
  )

  IF "%INSTALL_DIR%"=="" (
    SET INSTALL_DIR=%PREFIX%%VCVARS_PLATFORM%
  )

  IF "%1"=="" GOTO :EOF
  SETLOCAL enabledelayedexpansion
  IF "!%1_VER!"=="" (
    ECHO "**** SKIP BUILDING %1 w/o VERSION DEFINED, MAY LEAD BUILD ERROR ****"
    GOTO :EOF
  )
  ENDLOCAL

  :PARSE_CHAIN
    SHIFT
    IF "%1"=="" GOTO :PARSE_OK

    @REM
    @REM If there is already artifact (Github/Build),
    @REM NEVER call its build script any more ......
    @REM

    SETLOCAL enabledelayedexpansion
      IF NOT "!%1_VER!"=="" (
        SET BUILD_ARTIFACT=%1-!%1_VER!.%VCVARS_ARCH%-%LINK_TYPE%.7z
        IF EXIST !BUILD_ARTIFACT! GOTO :PARSE_CHAIN
      )
    ENDLOCAL

    IF EXIST %1.bat CALL %1
    GOTO :PARSE_CHAIN

  :PARSE_OK
    SET BUILD_TARGET=
    CALL :BUILD_CLEANARTIFACTS %INSTALL_DIR%

    SETLOCAL enabledelayedexpansion
      FOR %%i in (%*) DO (
        SET BUILD_ARTIFACT=%%i-!%%i_VER!.%VCVARS_ARCH%-%LINK_TYPE%.7z

        IF NOT DEFINED BUILD_TARGET (
          IF EXIST !BUILD_ARTIFACT! GOTO :EOF
          SET BUILD_TARGET=%%i
        ) ELSE (
          IF NOT "!%%i_VER!"=="" CALL :BUILD_UNPACK !BUILD_ARTIFACT! %INSTALL_DIR%
          IF EXIST REBUILD-%%i (
            CALL :TOUCH REBUILD-!BUILD_TARGET!
          )
        )
      )

      IF EXIST REBUILD-!BUILD_TARGET! GOTO :EOF

      IF NOT "!%BUILD_TARGET%_FORCEBUILD!"=="yes" (
        SET BUILD_ARTIFACT=%BUILD_TARGET%-!%BUILD_TARGET%_VER!.%VCVARS_ARCH%-%LINK_TYPE%.7z
        IF NOT EXIST !BUILD_ARTIFACT! CALL :BUILD_FROMGITHUB !BUILD_ARTIFACT!
        IF EXIST !BUILD_ARTIFACT! (
          CALL :BUILD_CLEANARTIFACTS %INSTALL_DIR%
          GOTO :EOF
        )
      )

      ECHO "Create REBUILD FLAG FOR !BUILD_TARGET! ..."
      CALL :TOUCH REBUILD-!BUILD_TARGET!
    ENDLOCAL

  GOTO :EOF
  @REM }}}}

:BUILD_FROMGITHUB
  @REM ------------------------------------------------------------------{{{{
  @REM Pack already build GNU artifacts into 7z package...
  @REM

  IF NOT "%APPVEYOR_REPO_NAME%"=="" (
    IF "%~1"=="" (
      ECHO "Nothing to download from github..."
      GOTO :EOF
    ) ELSE (
      ECHO "Download https://github.com/%APPVEYOR_REPO_NAME%/releases/download/vc%VSVER%.%PLATFORM%/%~1"
      curl -fsSL -o %~1 "https://github.com/%APPVEYOR_REPO_NAME%/releases/download/vc%VSVER%.%PLATFORM%/%~1"
    )
  ) ELSE (
    ECHO "NO REPO information from github ..."
  )

  GOTO :EOF
  @REM }}}}

:BUILD_CLEANARTIFACTS
  @REM ------------------------------------------------------------------{{{{
  @REM Clean build destination DIR for clean package...
  @REM

  IF EXIST %~1 RD /S/Q %~1

  GOTO :EOF
  @REM }}}}

:BUILD_PACK
  @REM ------------------------------------------------------------------{{{{
  @REM Pack already build GNU artifacts into 7z package...
  @REM

  IF NOT "%APPVEYOR_BUILD_FOLDER%"=="" (
    CD %APPVEYOR_BUILD_FOLDER%
  )

  IF EXIST %~2% (
    7z a %~1 %~2\* > nul
    RD /S/Q %~2
  )
  GOTO :EOF
  @REM }}}}

:BUILD_UNPACK
  @REM ------------------------------------------------------------------{{{{
  @REM UnPack GNU artifacts
  @REM

  IF EXIST %~1 (
    7z x -y %~1 -o%~2 > nul
  )
  GOTO :EOF
  @REM }}}}

:TOUCH
  @REM ------------------------------------------------------------------{{{{
  @REM Much likely the UNIX style touch, support multiple files.
  @REM Update file Modified Timestamp if file already exists.
  @REM Otherwise, create a NEW empty file
  @REM

  FOR %%a IN (%*) DO (
    IF EXIST "%%~a" (
      PUSHD "%%~dpa" && ( COPY /b "%%~nxa"+,, & POPD )
    ) ELSE (
      IF NOT EXIST "%%~dpa" MD "%%~dpa"
      TYPE nul > "%%~fa"
    )
  ) >nul 2>&1

  GOTO :EOF
  @REM }}}}
