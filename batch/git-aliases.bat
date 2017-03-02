@echo off
setlocal 
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases
set wrapper=%~dp0git-wrapper.bat

doskey gts=%wrapper% status $*
doskey gtcm=git commit -am $*
doskey gtps=git push -u origin head
doskey gtpl=git pull origin master
doskey gtb=%wrapper% branch $*
doskey gtch=%wrapper% checkout $*

echo Initializing GIT wrapper
call %wrapper% init