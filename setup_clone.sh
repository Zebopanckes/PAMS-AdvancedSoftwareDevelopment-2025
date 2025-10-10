#!/bin/bash
# Setup script for cloned PAMS repository

echo "========================================="
echo "  PAMS Repository Setup"
echo "========================================="
echo ""

# Create asset directories if they don't exist
echo "Creating asset directories..."
mkdir -p assets/images
mkdir -p assets/animations
mkdir -p assets/icons

# Create .gitkeep files
touch assets/images/.gitkeep
touch assets/animations/.gitkeep
touch assets/icons/.gitkeep

echo "✅ Asset directories created"
echo ""

# Enable Windows desktop support
echo "Enabling Windows desktop support..."
flutter config --enable-windows-desktop

# Create Windows platform files
echo "Creating Windows platform files..."
flutter create --platforms=windows .

# Get dependencies
echo "Installing dependencies..."
flutter pub get

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run 'flutter doctor' to verify setup"
echo "2. Run 'flutter run -d windows' to launch app"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
