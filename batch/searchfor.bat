@echo off

setlocal enableDelayedExpansion

set extensions=*.*
set query=
:argsIterate
if not "%1"=="" (
  REM if query is set already we don't accept params any more
  if "!query!"=="" (
    set value=%1
    REM check if this is a param
    if "!value:~0,1!"=="-" (
      if "%1"=="-ext" (
        set extensions=%2
        shift
      )
      if "%1"=="-type" (
        if "%2"=="code" (
          set extensions="*.ts *.tsx *.css *.cs *.cshtml *.ini *.bond"
        )
        if "%2"=="client" (
          set extensions="*.ts *.tsx *.css"
        )
        if "%2"=="server" (
          set extensions="*.cs *.cshtml"
        )
        if "%2"=="config" (
          set extensions="*.ini *.bond"
        )
        shift
      )
      shift
      goto :argsIterate
    )
  )
  
  set query=!query!%1
  
  if not "%2"=="" (
    set query=!query! 
    shift
    goto :argsIterate
  )
)

if "!query!"=="" (
  echo Query is missing
  goto :usage
)

set query=!query:"=!
set command=findstr /s /n /i /r /c:"!query!" !extensions:"=!

echo   Query:   !query!
echo   Ext:     !extensions:"=!
echo   Command: %command%

echo Proceed?
pause
echo.
%command%


goto :eof

:usage
echo.
echo Usage
echo    %~n0 [-ext "*.xml *.txt"] [-type code^|client^|server^|config] query
endlocal