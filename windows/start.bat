@echo off
title FFF Miner - Pearl (PRL) Pool (NVIDIA)
cd /d "%~dp0"

REM ================================================================
REM  EDIT THE SETTINGS BELOW, save the file, then double-click to mine.
REM ================================================================
set WALLET=prl1pYOUR_PRL_ADDRESS_HERE
set WORKER=rig01
set POOL_HOST=prl.kryptex.network
set POOL_PORT=7048
set AUTH_STYLE=array
REM ================================================================
REM  POOL_HOST/POOL_PORT/AUTH_STYLE: plain-TCP stratum only (no SSL).
REM  Tested and confirmed working:
REM    prl.kryptex.network:7048        AUTH_STYLE=array   (default)
REM    de.pearl.herominers.com:1200    AUTH_STYLE=object
REM  Other Pearl pools may use either style -- if authorize fails with
REM  "params must be an object" or similar, switch AUTH_STYLE.
REM ================================================================

if "%WALLET%"=="prl1pYOUR_PRL_ADDRESS_HERE" (
  echo.
  echo *** You need to edit this .bat file first. ***
  echo Right-click start.bat -^> Edit, set WALLET to your real prl1p... address,
  echo save and close, then double-click this file again.
  echo.
  pause
  exit /b 1
)

if not exist "fff.exe" (
  echo.
  echo *** fff.exe not found in this folder. ***
  echo.
  pause
  exit /b 1
)

echo === FFF Miner - Pearl Pool (NVIDIA) ===
echo Wallet: %WALLET%
echo Worker: %WORKER%
echo Pool:   %POOL_HOST%:%POOL_PORT%
echo.
echo Requires: NVIDIA GPU, Turing (RTX 20xx / Titan RTX) or newer, recent driver.
echo.

.\fff.exe --wallet %WALLET% --worker %WORKER% --host %POOL_HOST% --port %POOL_PORT% --auth-style %AUTH_STYLE%

echo.
echo *** Miner exited. Press any key to close this window. ***
pause >nul
