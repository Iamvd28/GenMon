# PowerShell script to move Flutter project to avoid path space issues

Write-Host "Moving Flutter project to avoid path space issues..." -ForegroundColor Green
Write-Host ""

# Create new directory without spaces
$newPath = "C:\flutter_projects\genmon4"

# Create the directory if it doesn't exist
if (!(Test-Path $newPath)) {
    New-Item -ItemType Directory -Path $newPath -Force
    Write-Host "Created directory: $newPath" -ForegroundColor Yellow
} else {
    Write-Host "Directory already exists: $newPath" -ForegroundColor Yellow
}

# Copy all files to new location
Write-Host ""
Write-Host "Copying project files..." -ForegroundColor Cyan
Copy-Item -Path "C:\projects by flutter\genmon4\*" -Destination $newPath -Recurse -Force

Write-Host ""
Write-Host "Project moved successfully!" -ForegroundColor Green
Write-Host "New location: $newPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Please:" -ForegroundColor White
Write-Host "1. Close your IDE/editor" -ForegroundColor White
Write-Host "2. Open the project from the new location: $newPath" -ForegroundColor White
Write-Host "3. Run: flutter clean" -ForegroundColor White
Write-Host "4. Run: flutter pub get" -ForegroundColor White
Write-Host "5. Run: flutter run" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to continue" 