@echo off
set hostsfile=%windir%\System32\drivers\etc\hosts


if not "%1"=="" if not "%2"=="" goto :addentry
if "%1"=="help" goto :printhelp
if "%1"=="/?" goto :printhelp
if "%1"=="edit" (start notepad.exe %hostsfile% && exit /b)

goto :EOF

:addentry
echo %2	%1 >> %hostsfile%
echo Entry added: %2	%1

goto :EOF

:printhelp
echo To add new host
echo 	knownhosts [host name] [ip]
echo To edit hosts file
echo 	knownhosts [edit]

