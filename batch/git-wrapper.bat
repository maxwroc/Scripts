@echo off

set GITBRANCH=
for /f %%I in ('git.exe rev-parse --abbrev-ref HEAD 2^> NUL') do set GITBRANCH=%%I

setlocal enableextensions enabledelayedexpansion

::overriding git command
doskey git=%0 $*

if "%1"=="branch" goto :branch
if "%1"=="checkout" goto :checkout
if "%1"=="/init" goto :setprompt

:executecommand

git.exe %*

goto :setprompt

:branch
if "%2" NEQ "" (
  set res=F
  ::check if second param is for deleting branch
  if "%2" EQU "-d" set res=T
  if "%2" EQU "-D" set res=T
  if "!res!"=="T" (
    if "%3" EQU "" (
      call :listbranches "Select branch to delete:" "Deleting branch" "git branch %2"
      goto :eof
    )
  )
  goto :executecommand
)

call :listbranches "Available branches:"
goto :setprompt

:checkout
::check if command has more than 1 arg
if "%2" NEQ "" (
  ::check if user wants to create a branch
  if "%2" EQU "-b" (
    ::check if new branch name was passed
    if "%3" NEQ "" (
      ::check if the intention is to create branch based on current one
      if "%4" EQU "" (
        if "%GITBRANCH%" NEQ "master" (
          echo You're trying to create a new branch based on the current one.
          echo     Y - Create new branch based on %GITBRANCH%
          echo     N - Create new branch based on master
          set /p answer=Was that your intention? 
          
          if /I "!answer!" NEQ "y" (
            echo Executing: git checkout %2 %3 master
            git checkout %2 %3 master
            goto :setprompt
          )
        )
      )
    )
  )
  goto :executecommand
)

call :listbranches "Select branch to checkout:" "Switching to branch" "git checkout"


:setprompt

endlocal

set GITBRANCH=
for /f %%I in ('git.exe rev-parse --abbrev-ref HEAD 2^> NUL') do set GITBRANCH=%%I

if "%GITBRANCH%" == "" (
    prompt $P$G
) else (
    prompt $E[42m%GITBRANCH%$E[0m $P$G
)

EXIT /B %ERRORLEVEL%

:listbranches

set info=%1
set confirmation=%2
set command=%3
echo %info:"=%

set /a count = 0
FOR /F "tokens=* USEBACKQ" %%F IN (`git.exe branch`) DO (
  set /a count += 1
  set branch=%%F
  set vector[!count!]=!branch:* =!
  ::check if it is a current branch
  if "!branch!" NEQ "!branch:* =!" (
    echo  [93m!count![0m. * [32m!branch:* =![0m
  ) else (
    echo  [93m!count![0m. !branch:* =!
  )
)

if exist "%confirmation%" (
  if !count! EQU 1 (
    echo You have only one branch.
    exit /b 0
  )
  
  set /p answer=Enter branch number: 
  if !answer! gtr !count! goto :eof
  if !answer! lss 1 goto :eof
  
  for /l %%n in (1,1,!count!) do (
    if %%n==!answer! (
      ::show message 
      echo %confirmation:"=% [93m!vector[%%n]![0m
      echo.
      
      ::execute command with branch param
      call %command:"=% !vector[%%n]!
      goto :setprompt
    )
  )
)

exit /b 0

