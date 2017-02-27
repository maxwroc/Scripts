@echo off
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases
set wrapper=%wrapper%

doskey gts=%wrapper% status
doskey gtc=git commit -am $*
doskey gtp=git push -u origin head
doskey gtpl=git pull origin master
doskey gtb=%wrapper% branch
doskey gtch=%wrapper% checkout $*
doskey git=%wrapper% $*

call %wrapper% init