@echo off
echo Moving Flutter project to avoid path space issues...
echo.

REM Create new directory without spaces
set "NEW_PATH=C:\flutter_projects\genmon4"

REM Create the directory if it doesn't exist
if not exist "%NEW_PATH%" (
    mkdir "%NEW_PATH%"
    echo Created directory: %NEW_PATH%
) else (
    echo Directory already exists: %NEW_PATH%
)

REM Copy all files to new location
echo.
echo Copying project files...
xcopy "C:\projects by flutter\genmon4\*" "%NEW_PATH%\" /E /I /H /Y

echo.
echo Project moved successfully!
echo New location: %NEW_PATH%
echo.
echo Please:
echo 1. Close your IDE/editor
echo 2. Open the project from the new location: %NEW_PATH%
echo 3. Run: flutter clean
echo 4. Run: flutter pub get
echo 5. Run: flutter run
echo.
pause 