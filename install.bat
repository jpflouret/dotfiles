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

rem Install claude config
if exist claude (
    mklink /d %USERPROFILE%\.claude %FILES%\claude
)

rem Install PowerShell profile
if exist powershell (
    if not exist %USERPROFILE%\Documents\PowerShell (
        mkdir %USERPROFILE%\Documents\PowerShell
    )
    if "%FORCE%"=="yes" (
        if exist %USERPROFILE%\Documents\PowerShell\profile.ps1 (
            del %USERPROFILE%\Documents\PowerShell\profile.ps1
        )
    )
    mklink %USERPROFILE%\Documents\PowerShell\profile.ps1 %FILES%\powershell\profile.ps1
)

popd
endlocal

