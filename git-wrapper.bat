@echo off
setlocal enableextensions enabledelayedexpansion

if "%1"=="branch" goto :branch

:executecommand

git.exe %*

goto :setprompt

:branch

if "%2" NEQ "" (
  if "%2" EQU "-d" (
    if "%3" EQU "" (
      call :listbranches "Select branch to delete:" "Deleting branch" "git branch -d"
      goto :eof
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

if !count! NEQ 1 (
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

