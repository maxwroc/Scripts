@echo off

setlocal enableDelayedExpansion

set extensions=*.*
set query=

:argsIterate

set param=%~1

if not "!param!"=="" (

  set paramValue=%~2

  REM if query is set already we don't accept params any more
  if "!query!"=="" (
    
    if "!param!"=="-h" goto :usage
    if "!param!"=="-help" goto :usage
    if "!param!"=="/h" goto :usage
    if "!param!"=="/help" goto :usage
    if "!param!"=="/?" goto :usage
  
    REM check if this is a param
    if "!param:~0,1!"=="-" (
    
      REM check if extensions param was passed
      if "!param!"=="-ext" (
        REM reset default
        set extensions=
        REM iterate over list of extensions
        for %%a in (!paramValue!) do (
          set ext=%%a
          REM check if we need to prefix it
          if not "!ext:~0,2!"=="*." set ext=*.!ext!
          REM add a space if some extensions are there already
          if not "!extensions!"=="" set extensions=!extensions! 
          set extensions=!extensions!!ext!
        )
        
        REM remove param value
        shift
      )
      
      REM check if file pattern was passed
      if "!param!"=="-file" (
        REM reset default
        set extensions=!paramValue!
        REM remove param value
        shift
      )
      
      REM check if type param was passed
      if "!param!"=="-type" (
        if "!paramValue!"=="code" (
          set extensions=*.ts *.tsx *.css *.cs *.cshtml *.ini *.bond
        )
        if "!paramValue!"=="client" (
          set extensions=*.ts *.tsx *.css
        )
        if "!paramValue!"=="server" (
          set extensions=*.cs *.cshtml
        )
        if "!paramValue!"=="config" (
          set extensions=*.ini *.bond
        )
        REM remove param value
        shift
      )
      
      REM remove param name
      shift
      goto :argsIterate
    )
  )
  
  REM concat query
  set query=!query!%1
  
  if not "!paramValue!"=="" (
    REM add a space after query
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
echo   Ext:     !extensions!
echo   Command: %command%

echo Proceed?
pause
echo.
%command%


goto :eof

:usage
echo.
echo Usage
echo    %~n0 [-ext "*.xml *.txt"] [-type code^|client^|server^|config] [-file pattern] query
echo.
echo Examples
echo    %~n0 -ext ini search query
echo    %~n0 -ext *.ini "search query"
echo    %~n0 -ext "ini txt" search query
echo    %~n0 -type code "search query"
echo    %~n0 -type code "search query"
echo    %~n0 -file *test*.cs "search query"
endlocal