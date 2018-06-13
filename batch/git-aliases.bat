@echo off
setlocal
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases
set wrapper=%~dp0git-prompt\dynamic-prompt /exec %~dp0git-prompt\git-wrapper.cmd

REM git status
doskey gts=%wrapper% status $*
REM git commit adding all unstaged files
doskey gtcm=git commit -am $*
REM git push
doskey gtps=git push -u origin head
REM git pull
doskey gtpl=git pull
REM git pull master
doskey gtplm=git pull origin master
REM git branch
doskey gtb=%wrapper% branch $*
REM git checkout
doskey gtch=%wrapper% checkout $*
REM git branch changes vs master (local)
doskey gtlc=git diff --name-status master..%GITBRANCH%
REM local clean up
doskey gtcl=git clean -fdX
REM open repo (url) in the browser
doskey gto=for /f %%a in ('git config --get remote.origin.url') do start %%a
doskey openrepo=for /f %%a in ('git config --get remote.origin.url') do start %%a

echo Initializing GIT wrapper
call %wrapper% /init