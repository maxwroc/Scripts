@echo off
setlocal 
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases
set wrapper=%~dp0git-wrapper.bat

doskey gts=%wrapper% status $*
doskey gtcm=%wrapper% commit -am $*
doskey gtps=%wrapper% push -u origin head
doskey gtpl=%wrapper% pull
doskey gtplm=%wrapper% pull origin master
doskey gtb=%wrapper% branch $*
doskey gtch=%wrapper% checkout $*
doskey gtmm=%wrapper% merge master
:: diff between current branch and master
doskey gtlc=%wrapper% diff --name-status master..%GITBRANCH%
:: last changes in specified dir
doskey gtdc=%wrapper% log --name-status -10 $*

echo Initializing GIT wrapper
call %wrapper% /init