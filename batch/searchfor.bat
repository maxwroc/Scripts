@echo off

setlocal enableDelayedExpansion

set extensionGroups[code]=*.ts *.tsx *.css *.cs *.cshtml *.ini *.bond
set extensionGroups[client]=*.ts *.tsx *.css
set extensionGroups[server]=*.cs *.cshtml
set extensionGroups[config]=*.ini *.bond

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
        call set types=%%extensionGroups[!paramValue!]%%
        if not "!types!"=="" (
          set extensions=!types!
        ) else (
          call :printError "Unknown type [!paramValue!]"
          goto :eof
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
set command=findstr /s /n /i /r /c:"[33m!query![0m" [36m!extensions:"=![0m

echo   Query:   !query!
echo   Ext:     !extensions!
echo   Command: %command%

echo Proceed?
pause
echo.
%command%


goto :eof

:printError
echo.
echo [31mError: %~1 [0m
echo.
echo To get a list of available parameterst type: [33m%~n0 -h [0m
exit /b 1

:usage
echo.
echo Usage
echo    %~n0 [-ext extensions] [-type value] [-file pattern] query
echo.
echo    -ext
echo        Space separated file extensions (wildcrds are not necessary).
echo        If specyfing more than one extension they must be wrapped in quotes.
echo.
echo    -type values:
for /f "tokens=2,3 delims=[]=" %%a in ('set extensionGroups') do (
  echo        %%a	%%b
)
echo.
echo    -file
echo        Pattern can be any string with wildcards. For example: *Look*for.txt
echo.
echo Examples
echo    %~n0 -ext ini search query
echo    %~n0 -ext *.ini "search query"
echo    %~n0 -ext "ini txt" search query
echo    %~n0 -type code "search query"
echo    %~n0 -type code "search query"
echo    %~n0 -file *test*.cs "search query"
endlocal