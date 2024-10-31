@echo off

:: Extract API_BRANCH and echo its value
setlocal enabledelayedexpansion
for /f %%a in ('type app_build\build_config.json ^| jq -r .api.default_branch') do set API_BRANCH=%%a
echo API_BRANCH=!API_BRANCH!

:: Extract API_VERSION and echo its value
for /f %%a in ('type app_build\build_config.json ^| jq -r .api.version') do set API_VERSION=%%a
echo API_VERSION=!API_VERSION!

:: Create FILE_NAME variable
set FILE_NAME=mm2_!API_VERSION!-wasm.zip
echo FILE_NAME=!FILE_NAME!

:: Create DOWNLOAD_URL variable
set DOWNLOAD_URL=https://sdk.devbuilds.komodo.earth/!API_BRANCH!/!FILE_NAME!
echo DOWNLOAD_URL=!DOWNLOAD_URL!

:: Download the file using curl (you need to have curl installed)
curl -LO !DOWNLOAD_URL!

:: Remove contents of build, web/src/mm2, and web/dist directories
del /q /s /f build\*
del /q /s /f web\src\mm2\*
del /q /s /f web\dist\*

:: Unzip the downloaded file to ./web/src/mm2/
powershell -command Expand-Archive -Path !FILE_NAME! -DestinationPath ./web/src/mm2/

:: List the contents of ./web/src/mm2/
dir /b /s ./web/src/mm2/

:: List the contents of the parent directory (assuming this is where the script is run from)
dir /b /s ..

:: Calculate the shasum (checksum) of ./web/src/mm2/mm2lib_bg.wasm (you need to have a shasum tool installed)
shasum ./web/src/mm2/mm2lib_bg.wasm

