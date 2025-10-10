# Setup script for cloned PAMS repository

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  PAMS Repository Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Create asset directories if they don't exist
Write-Host "Creating asset directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "assets/images" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/animations" | Out-Null
New-Item -ItemType Directory -Force -Path "assets/icons" | Out-Null

# Create .gitkeep files
New-Item -ItemType File -Force -Path "assets/images/.gitkeep" | Out-Null
New-Item -ItemType File -Force -Path "assets/animations/.gitkeep" | Out-Null
New-Item -ItemType File -Force -Path "assets/icons/.gitkeep" | Out-Null

Write-Host "✅ Asset directories created" -ForegroundColor Green
Write-Host ""

# Enable Windows desktop support
Write-Host "Enabling Windows desktop support..." -ForegroundColor Yellow
flutter config --enable-windows-desktop

# Create Windows platform files
Write-Host "Creating Windows platform files..." -ForegroundColor Yellow
flutter create --platforms=windows .

# Get dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run 'flutter doctor' to verify setup" -ForegroundColor White
Write-Host "2. Run 'flutter run -d windows' to launch app" -ForegroundColor White
Write-Host ""
Write-Host "Default credentials:" -ForegroundColor Cyan
Write-Host "  Username: admin" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""

pause
