@echo off
setlocal
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases
set wrapper=%~dp0git-prompt\dynamic-prompt /exec %~dp0git-prompt\git-wrapper.cmd

doskey gts=%wrapper% status $*
doskey gtcm=git commit -am $*
doskey gtps=git push -u origin head
doskey gtpl=git pull
doskey gtplm=git pull origin master
doskey gtb=%wrapper% branch $*
doskey gtch=%wrapper% checkout $*
doskey gtlc=git diff --name-status master..%GITBRANCH%
doskey gtcl=git clean -fdX

echo Initializing GIT wrapper
call %wrapper% /init