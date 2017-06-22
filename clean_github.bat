@ECHO off

@REM
@REM Github Provides API for release deletion, but leaves tag untouched.
@REM And there is no API currently available for tag deletion remotely
@REM Use git command for that operation...
@REM

curl -s -H "Authorization: token %GITHUB_TOKEN%" https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases > github_release.txt
FOR /F "usebackq tokens=*" %%G IN (`FINDSTR /I /C:"API rate limit exceeded" github_release.txt`) DO (
  ECHO "GITHUB API rate limit reached...... CLEAN Job skipped......"
  GOTO :EOF
)

SETLOCAL enabledelayedexpansion
  SET /A GITHUB_TAGSEQ=0
  SET GITHUB_RELEASE=

  FOR /F "usebackq delims=," %%G IN (`FINDSTR "\"html_url\":.*/releases/tag/.*" github_release.txt`) DO (
    FOR /F "usebackq" %%H IN (`ECHO %%G ^| FINDSTR /I "vc%VSVER%.%PLATFORM%"`) DO (
      GOTO :TAGFIND
    )
    SET /A GITHUB_TAGSEQ+=1
  )
  ECHO "NO RELEASE Found..."
  GOTO :EOF

  :TAGFIND
  FOR /F "usebackq delims=," %%G IN (`FINDSTR "\"url\":.*/releases/[0-9]" github_release.txt`) DO (
    IF "!GITHUB_TAGSEQ!"=="0" (
      FOR /F "usebackq tokens=2 delims= " %%H IN ('%%G') DO (
        SET GITHUB_RELEASE=%%H
        GOTO :RELEASEFIND
      )
    )
    SET /A GITHUB_TAGSEQ-=1
  )

  :RELEASEFIND
  IF NOT "%GITHUB_RELEASE%"=="" (
    ECHO "DELETE vc%VSVER%.%PLATFORM%: %GITHUB_RELEASE%"
    curl -s -H "Authorization: token %GITHUB_TOKEN%" -X DELETE %GITHUB_RELEASE%
  )
ENDLOCAL

ECHO "DELETE remote tags vc%VSVER%.%PLATFORM% ..."
git config remote.origin.url https://%GITHUB_TOKEN%@github.com/%APPVEYOR_REPO_NAME%
git push --delete origin vc%VSVER%.%PLATFORM%
git config remote.origin.url https://github.com/%APPVEYOR_REPO_NAME%

