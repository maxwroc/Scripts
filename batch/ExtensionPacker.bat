@echo off

set zip="C:\Program Files\7-Zip\7z.exe5"

if not exist %zip% (
  call :error 7-zip not found: %zip%
  goto :eof
)

if not exist %1\manifest.json (
  call :error "manifest.json not found: %1\manifest.json"
  goto :eof
)


goto next
REM for /f %%f in ('dir /s /b %1') do echo %%f

set tmpDir=%CD%\tempDir

mkdir %tmpDir%
xcopy /s %1\* %tmpDir%

del /s %tmpDir%\*.ts

:next


echo dupa
goto :eof
%7zip% a -tzip "%2.zip" "%tmpDir%\*"


for /F delims^=^"^ tokens^=2^,4 %%g IN (%tmpDir%\manifest.json) DO (
  if %%g==version (
    set version=%%h
  )
)

goto :eof

:error
echo Error: %*

goto :eof