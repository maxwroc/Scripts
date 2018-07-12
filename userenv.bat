@echo off
if "%1" equ "/hlp" goto :hlp

echo Initializing local variables

set scriptsdir=%~dp0
set programsdir=C:\Programs
set startdir=D:\Projects

if exist %scriptsdir%customvars.bat (
  echo Applying custom script
  call %scriptsdir%customvars.bat
)

::switch to startdir only if nodirswitch flag is not set
if not defined nodirswitch cd /D %startdir%

call %scriptsdir%batch\git-aliases.bat

doskey n=notepad $*
doskey cdscripts=cd /D %scriptsdir%
doskey hosts=notepad "C:\Windows\System32\drivers\etc\hosts"
doskey ls=dir /B $*
doskey hlp=%0 /hlp
doskey hlpall=doskey /macros:all $*
doskey cfg=notepad %scriptsdir%\userenv.bat
doskey md5=%programsdir%\Checksum\fciv.exe -md5 $1
doskey ip=for /f "tokens=14" %%a in ('ipconfig ^^^| findstr "IPv4"') do @echo IP: %%a
doskey rww=%scriptsdir%\batch\whack_all_slashes.bat $*
doskey searchfor=%scriptsdir%batch\searchfor.bat $*
doskey whereis=dir /b /s $*
doskey ps=powershell $*
doskey restartwifi=powershell -File "%scriptsdir%PowerShell\Restart-WiFiAdapter.ps1"
doskey rwifi=powershell -File "%scriptsdir%PowerShell\Restart-WiFiAdapter.ps1"
doskey cheat=powershell $w=New-Object System.Net.WebClient;$w.Headers.Add('User-Agent','curl/7.16.3');Write-Host 'https://cht.sh/$*';$w.DownloadString('https://cht.sh/$*')
doskey cht=powershell $w=New-Object System.Net.WebClient;$w.Headers.Add('User-Agent','curl/7.16.3');Write-Host 'https://cht.sh/$*';$w.DownloadString('https://cht.sh/$*')

if defined localservername doskey %localservername%=%programsdir%\ansicon\x86\ansicon.exe %programsdir%\plink.exe -ssh %localserver% -pw %localserverpass%

echo.
echo Hello !!! [32mYou're ready to go[0m
echo.
echo Type [93mhlp[0m to see env options or [93mcfg[0m to configure them.

goto :eof




:hlp

setlocal enabledelayedexpansion
::required by middots below
chcp 65001
SET "spaces=·······························"

for /f "tokens=3,* delims=:^=" %%a in ('findstr /s /i doskey %scriptsdir%*.bat') do (
  set "alias=%%a"
  ::check if it starts with doskey keyword (skipping code which doesn't set dos keys)
  if "!alias:~0,6!"=="doskey" (
    ::removing everything up to and including "doskey" (we could use "~7," instead)
    set alias=!alias:*doskey=!
    set "command=%%b"
    call :formatout
  )
)

goto :eof

:formatout
call :padright alias 20
echo  %alias% %command%
goto :eof

:padright
call set padded=%%%1%% %spaces%
call set %1=%%padded:~0,%2%%
goto :eof

:padleft
call set padded=%spaces%%%%1%%
call set %1=%%padded:~-%2%%
goto :eof
