# PAMS Quick Start Script
# Run this after Flutter is installed

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PAMS Project Quick Start" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue

if ($null -eq $flutterCheck) {
    Write-Host "❌ Flutter is not installed or not in PATH!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🎯 Recommended Installation Location (No Admin Rights Needed):" -ForegroundColor Yellow
    Write-Host "   C:\Users\alecb\flutter" -ForegroundColor White
    Write-Host ""
    Write-Host "📥 Quick Install Steps:" -ForegroundColor Cyan
    Write-Host "1. Open PowerShell and run:" -ForegroundColor White
    Write-Host "   Set-Location C:\Users\alecb\Documents" -ForegroundColor Gray
    Write-Host "   Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip' -OutFile 'flutter.zip'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Extract Flutter:" -ForegroundColor White
    Write-Host "   Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\Users\alecb\'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Add to PATH:" -ForegroundColor White
    Write-Host "   `$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')" -ForegroundColor Gray
    Write-Host "   [Environment]::SetEnvironmentVariable('Path', `"`$userPath;C:\Users\alecb\flutter\bin`", 'User')" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Close and reopen PowerShell, then run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "📚 See SETUP_GUIDE.md for detailed instructions" -ForegroundColor Cyan
    Write-Host ""
    
    # Offer to download Flutter automatically
    $response = Read-Host "Would you like to download Flutter now? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host ""
        Write-Host "Downloading Flutter..." -ForegroundColor Yellow
        $downloadPath = "$env:USERPROFILE\Downloads\flutter.zip"
        try {
            Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip" -OutFile $downloadPath
            Write-Host "✅ Downloaded to: $downloadPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Yellow
            Write-Host "1. Extract $downloadPath to C:\Users\alecb\" -ForegroundColor White
            Write-Host "2. Add C:\Users\alecb\flutter\bin to PATH (see instructions above)" -ForegroundColor White
            Write-Host "3. Restart PowerShell and run this script again" -ForegroundColor White
        }
        catch {
            Write-Host "❌ Download failed. Please download manually from:" -ForegroundColor Red
            Write-Host "   https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
        }
    }
    
    Write-Host ""
    pause
    exit
}

Write-Host "✅ Flutter found at: $($flutterCheck.Source)" -ForegroundColor Green
Write-Host ""

# Show Flutter version
Write-Host "Flutter version:" -ForegroundColor Yellow
flutter --version
Write-Host ""

# Run Flutter doctor
Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Enable Windows desktop
Write-Host "Enabling Windows desktop support..." -ForegroundColor Yellow
flutter config --enable-windows-desktop
Write-Host ""

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Check for devices
Write-Host "Available devices:" -ForegroundColor Yellow
flutter devices
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To run the application:" -ForegroundColor Cyan
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Cyan
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Green
Write-Host ""

pause
