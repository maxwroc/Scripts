@echo off
echo Initializing local variables

set scriptsdir=%~dp0
set programsdir=C:\Programs
set startdir=D:\Projects

if exist %scriptsdir%customvars.bat call %scriptsdir%customvars.bat

doskey hosts=notepad "C:\Windows\System32\drivers\etc\hosts"
doskey ls=dir /B
doskey hlp=doskey /macros:all
doskey cfg=notepad %scriptsdir%\userenv.bat
doskey md5=%programsdir%\Checksum\fciv.exe -md5 $1
doskey ip=for /f "tokens=14" %%a in ('ipconfig ^^^| findstr "IPv4"') do @echo IP: %%a
doskey rww=%scriptsdir%\batch\whack_all_slashes.bat $*

if defined localservername doskey %localservername%=%programsdir%\ansicon\x86\ansicon.exe %programsdir%\plink.exe -ssh %localserver% -pw %localserverpass%

chdir /D %startdir%

echo.
echo Hello !!! [32mYou're ready to go[0m
echo.
echo Type [93mhlp[0m to see env options or [93mcfg[0m to configure them.
