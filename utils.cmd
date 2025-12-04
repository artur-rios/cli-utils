@echo off
setlocal

REM Simple dispatcher to route to PowerShell command scripts
if "%~1"=="" goto :usage

set CMD=%~1
shift

REM Built-in 'list' command: enumerate available scripts
if /I "%CMD%"=="list" goto :list


REM Resolve ROOT to a dispatcher location that has both 'commands' and 'tests'
set ROOT=%~dp0
if exist "%ROOT%commands\" if exist "%ROOT%tests\" goto :root_ok
for /f "delims=" %%X in ('where utils.cmd 2^>nul') do (
  if exist "%%~dpXcommands\" if exist "%%~dpXtests\" (
    set ROOT=%%~dpX
    goto :root_ok
  )
)

:root_ok

set SCRIPT=%ROOT%commands\%CMD%.ps1
if exist "%SCRIPT%" goto :run
set SCRIPT=%ROOT%tests\%CMD%.ps1
if exist "%SCRIPT%" goto :run
echo Unknown command: %CMD%
echo Tried: %SCRIPT%
echo Script: %~f0
echo ScriptDir: %~dp0
echo CWD: %CD%
goto :usage

:run

REM Prefer pwsh, fallback to powershell
where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
  if /I "%CMD%"=="init-proj" (
    pwsh -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT%' -NameOrPath '%~1'"
  ) else (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
  )
) else (
  if /I "%CMD%"=="init-proj" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%SCRIPT%' -NameOrPath '%~1'"
  ) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
  )
)

exit /b %ERRORLEVEL%

:usage
echo Usage: utils ^<command^> [args]
echo.
echo Commands:
echo   init-proj ^<name-or-path^>  - create a project from 'project-template'
echo   ktype [timeout]             - type 'echo Hello World' at intervals in cmd
echo   test-init-proj              - smoke test for init-proj
echo   test-ktype                  - smoke test for ktype
echo   list                       - list available commands and tests
exit /b 1

:list
REM Resolve ROOT for list independently (when invoked before main resolution)
set ROOT=%~dp0
if exist "%ROOT%commands\" if exist "%ROOT%tests\" goto :list_root_ok
for /f "delims=" %%X in ('where utils.cmd 2^>nul') do (
  if exist "%%~dpXcommands\" if exist "%%~dpXtests\" (
    set ROOT=%%~dpX
    goto :list_root_ok
  )
)

:list_root_ok
echo Dispatcher root: %ROOT%
echo Available commands:
if exist "%ROOT%commands\*.ps1" (
  for %%F in (%ROOT%commands\*.ps1) do echo   %%~nF
) else (
  echo   (none)
)
echo Available tests:
if exist "%ROOT%tests\*.ps1" (
  for %%F in (%ROOT%tests\*.ps1) do echo   %%~nF
) else (
  echo   (none)
)
exit /b 0
