@echo on
where git.exe >nul 2>&1
IF %ERRORLEVEL% NEQ 0 goto :EOF

echo Initializing GIT aliases

doskey gts=%~dp0git-wrapper.bat status
doskey gtc=git commit -am $*
doskey gtp=git push -u origin head
doskey gtpl=git pull origin master
doskey gtb=%~dp0git-wrapper.bat branch
doskey gtch=%~dp0git-wrapper.bat checkout $*
doskey git=%~dp0git-wrapper.bat $*