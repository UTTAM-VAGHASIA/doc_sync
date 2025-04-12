@echo off
REM This script decodes the base64 keystore file and saves it to the correct location
REM Usage: decode_keystore.bat

SETLOCAL

REM Path to the base64 encoded keystore file
SET BASE64_FILE=keystore_base64.txt

REM Path where the decoded keystore should be saved
SET KEYSTORE_FILE=upload-keystore.jks

REM Check if the base64 file exists
IF NOT EXIST "%BASE64_FILE%" (
  echo Error: %BASE64_FILE% not found!
  exit /b 1
)

REM Decode the base64 content and save it as the keystore file
REM Using PowerShell for base64 decoding
powershell -Command "[System.IO.File]::WriteAllBytes('%KEYSTORE_FILE%', [System.Convert]::FromBase64String([System.IO.File]::ReadAllText('%BASE64_FILE%')))"

REM Check if the decoding was successful
IF %ERRORLEVEL% EQU 0 (
  echo Successfully decoded keystore to %KEYSTORE_FILE%
) ELSE (
  echo Error: Failed to decode keystore!
  exit /b 1
)

ENDLOCAL