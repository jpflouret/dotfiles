@echo off
setlocal
pushd

set FORCE=no
if "%1"=="-f" set FORCE=yes

set FILES=%~dp0files

cd %FILES%
for %%i in (*) do (
    if "%FORCE%"=="yes" (
        if exist %USERPROFILE%\.%%i (
            del %USERPROFILE%\.%%i
        )
    )
    mklink %USERPROFILE%\.%%i %FILES%\%%i
)

rem Install vimfiles also
if exist vim (
    mklink /d %USERPROFILE%\.vim %FILES%\vim
    mklink /d %USERPROFILE%\vimfiles %FILES%\vim
)

popd
endlocal

