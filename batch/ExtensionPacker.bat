@echo off
setlocal EnableDelayedExpansion

for /f %%i in ('where 7z') do set zip=%%i
if "%zip%" neq "" goto 7zFound

set zip="C:\Program Files\7-Zip\7z.exe"
set zip2="C:\Program Files (x86)\7-Zip\7z.exe"
set version=
set appName=

if not exist %zip% (
  REM Check second possible location
  if not exist %zip2% (
    call :error 7-zip not found: %zip%
    goto :eof
  ) else (
    set zip=%zip2%
  )
)

:7zFound

if not exist %~1\manifest.json (
  call :error "manifest.json not found: %~1\manifest.json"
  goto :eof
)

REM extract extension name and version
for /F delims^=^"^ tokens^=2^,4 %%g IN (%~1\manifest.json) DO (
  if %%g==version (
    set version=%%h
  )
  if %%g==name (
    set appName=%%h
    REM remove spaces
    set appName=!appName: =!
  )
)

REM check if name and version fields were found
if "!version!"=="" (
  call :error "Problem with parsing manifest file - cannot find extension version field"
  goto :eof
)
if "!appName!"=="" (
  call :error "Problem with parsing manifest file - cannot find extension name field"
  goto :eof
)

set zipFile=!appName!_v!version!.zip

if exist %zipFile% (
  call :error "File for this version already exists: %zipFile%"
  goto :eof
)

set tmpDir=%CD%\extensionPackerTemp

REM create directory for temporary files
mkdir %tmpDir%
if %errorlevel% neq 0 (
  call :error "Failed creating a temporory folder"
  goto :eof
)

REM copy extension files to temporary dir
xcopy /s %~1\* %tmpDir%
if %errorlevel% neq 0 (
  call :error "Failed copying files"
  goto :eof
)

REM remove TS files
del /s %tmpDir%\*.ts
del /s %tmpDir%\*.map

REM compress remaining files
!zip! a -tzip "%zipFile%" "%tmpDir%\*"
if %errorlevel% neq 0 (
  call :error "Failed compressing files"
  goto :eof
)

REM cleanup 
rmdir /s /q %tmpDir%

echo.
echo Extension successfully packed: %zipFile%

goto :eof

:error
echo Error: %*

goto :eof