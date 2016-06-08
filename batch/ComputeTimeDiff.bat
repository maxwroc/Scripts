@echo off

setlocal ENABLEEXTENSIONS

if [%1] == [] goto Usage
if [%2] == [] goto Usage

set start_time=%1
set stop_time=%2
set label=%3

if [%label%] == [] set label=Total time

set TEMPRESULT=%start_time:~0,2%
call:FN_REMOVELEADINGZEROS
set start_hour=%TEMPRESULT%
@rem
set TEMPRESULT=%start_time:~3,2%
call:FN_REMOVELEADINGZEROS
set start_min=%TEMPRESULT%
@rem
set TEMPRESULT=%start_time:~6,2%
call:FN_REMOVELEADINGZEROS
set start_sec=%TEMPRESULT%
@rem
set TEMPRESULT=%start_time:~9,2%
call:FN_REMOVELEADINGZEROS
set start_hundredths=%TEMPRESULT%

set TEMPRESULT=%stop_time:~0,2%
call:FN_REMOVELEADINGZEROS
set stop_hour=%TEMPRESULT%
@rem
set TEMPRESULT=%stop_time:~3,2%
call:FN_REMOVELEADINGZEROS
set stop_min=%TEMPRESULT%
@rem
set TEMPRESULT=%stop_time:~6,2%
call:FN_REMOVELEADINGZEROS
set stop_sec=%TEMPRESULT%
@rem
set TEMPRESULT=%stop_time:~9,2%
call:FN_REMOVELEADINGZEROS
set stop_hundredths=%TEMPRESULT%

set /A start_total=(((((%start_hour%*60)+%start_min%)*60)+%start_sec%)*100)+%start_hundredths%
set /A stop_total=(((((%stop_hour%*60)+%stop_min%)*60)+%stop_sec%)*100)+%stop_hundredths%

set /A total_time=%stop_total% - %start_total%

set /A total_hundredths=%total_time% %% 100
set total_hundredths=00%total_hundredths%
set total_hundredths=%total_hundredths:~-2%
set /A total_time=%total_time% / 100

set /A total_sec="%total_time% %% 60"
set total_sec=00%total_sec%
set total_sec=%total_sec:~-2%
set /A total_time=%total_time% / 60

set /A total_min="%total_time% %% 60"
set total_min=00%total_min%
set total_min=%total_min:~-2%
set /A total_time=%total_time% / 60

set /A total_hour="%total_time% %% 60"
@rem Handle if it wrapped around over midnight
if "%total_hour:~0,1%"=="-" set /A total_hour=%total_hour% + 24

echo %label%:	%total_hour%:%total_min%:%total_sec%.%total_hundredths%


@rem --------------------------------------------
@rem Exit the BAT Program
endlocal
goto END

@rem --------------------------------------------
@rem FN_REMOVELEADINGZEROS function
@rem  Used to remove leading zeros from Decimal
@rem  numbers so they are not treated as Octal.
:FN_REMOVELEADINGZEROS
if "%TEMPRESULT%"=="0" goto END
if "%TEMPRESULT:~0,1%" NEQ "0" goto END
set TEMPRESULT=%TEMPRESULT:~1%
goto FN_REMOVELEADINGZEROS


:Usage
echo   Usage:
echo      %~n0 startTime endTime [label]
echo.
echo   Example:
echo      %~n0 14:40:02.49 %%TIME%%
goto END


@rem --------------------------------------------
@rem BAT PROGRAM / FUNCTION FILE EXIT
:END