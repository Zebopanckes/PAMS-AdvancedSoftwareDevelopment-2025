# PAMS - Setup Guide for Cloned Repository

## Prerequisites

Before setting up the project, ensure you have:

- ✅ Flutter SDK installed (3.0.0 or higher)
- ✅ Visual Studio Build Tools 2022 with C++ workload
- ✅ Windows Developer Mode enabled
- ✅ Git installed

## Quick Setup

### Option 1: Automated Setup (Recommended)

**Windows PowerShell:**
```powershell
.\setup_clone.ps1
```

**Git Bash/Linux:**
```bash
bash setup_clone.sh
```

### Option 2: Manual Setup

1. **Create asset directories:**
   ```bash
   mkdir -p assets/images assets/animations assets/icons
   ```

2. **Enable Windows desktop:**
   ```bash
   flutter config --enable-windows-desktop
   ```

3. **Create Windows platform files:**
   ```bash
   flutter create --platforms=windows .
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Verify setup:**
   ```bash
   flutter doctor
   ```

6. **Run the application:**
   ```bash
   flutter run -d windows
   ```

## Common Issues After Cloning

### Issue 1: "MyApp isn't a class"
**Solution:** The test file has been updated to use `PAMSApp` instead of `MyApp`. Run `git pull` to get the latest changes.

### Issue 2: Asset folders don't exist
**Solution:** Run the setup script or manually create the asset directories as shown above.

### Issue 3: Windows platform missing
**Solution:** Run `flutter create --platforms=windows .` to generate Windows-specific files.

### Issue 4: Symlink errors
**Solution:** Enable Developer Mode in Windows Settings (`Win + R` → `ms-settings:developers`)

### Issue 5: pubspec.yaml asset errors
**Solution:** The asset folders are now tracked in Git with `.gitkeep` files. After pulling, run `flutter pub get`.

## What's Included in Git

### ✅ Tracked Files
- All source code (`lib/`)
- Configuration files (`pubspec.yaml`, `analysis_options.yaml`)
- Documentation (`*.md` files)
- Asset directory structure (with `.gitkeep` files)
- Test files (`test/`)
- Setup scripts (`setup_clone.ps1`, `setup_clone.sh`)

### ❌ Not Tracked (Generated Locally)
- `build/` folder
- `windows/flutter/` folder (generated files)
- `.dart_tool/` folder
- Database files (`*.db`)
- IDE-specific files (`.vscode/`, `.idea/`)
- Asset contents (only `.gitkeep` files are tracked)

## Default Login

After setup, use these credentials:

| Field    | Value    |
|----------|----------|
| Username | admin    |
| Password | admin123 |

## Verification Steps

After setup, verify everything works:

```bash
# 1. Check Flutter installation
flutter doctor

# 2. Check dependencies
flutter pub get

# 3. Run tests
flutter test

# 4. Launch app
flutter run -d windows
```

## Need Help?

- Check **SETUP_GUIDE.md** for detailed Flutter installation
- Check **QUICK_REFERENCE.md** for common commands
- Check **README.md** for project overview

## Git Workflow

### First Time Setup
```bash
git clone https://github.com/Zebopanckes/PAMS-AdvancedSoftwareDevelopment-2025.git
cd PAMS-AdvancedSoftwareDevelopment-2025
.\setup_clone.ps1  # or bash setup_clone.sh
```

### Pulling Updates
```bash
git pull origin main
flutter pub get
flutter run -d windows
```

### Pushing Changes
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

## Project Structure

```
PAMS-AdvancedSoftwareDevelopment-2025/
├── lib/                    # ✅ Tracked - Source code
│   ├── core/              # Core functionality
│   │   ├── models/        # Data models
│   │   ├── routes/        # Navigation
│   │   ├── services/      # Business logic
│   │   └── theme/         # App theming
│   └── features/          # Feature modules
│       ├── auth/          # Authentication
│       ├── dashboard/     # Main dashboard
│       ├── tenants/       # Tenant management
│       ├── apartments/    # Apartment management
│       ├── payments/      # Payment tracking
│       └── maintenance/   # Maintenance requests
├── test/                   # ✅ Tracked - Tests
├── assets/                 # ✅ Tracked - Asset folders
│   ├── images/            # Image assets
│   ├── animations/        # Lottie animations
│   └── icons/             # Custom icons
├── docs/                   # ✅ Tracked - Documentation
├── windows/                # ⚠️ Partially tracked
├── build/                  # ❌ Not tracked
├── .dart_tool/             # ❌ Not tracked
├── pubspec.yaml            # ✅ Tracked
├── setup_clone.ps1         # ✅ Tracked - Windows setup
├── setup_clone.sh          # ✅ Tracked - Linux/Mac setup
└── README.md               # ✅ Tracked
```

## Success Indicators

After setup, you should see:

1. ✅ `flutter doctor` shows green checkmarks for Flutter and Visual Studio
2. ✅ `flutter pub get` completes without errors
3. ✅ `flutter test` passes all tests
4. ✅ `flutter run -d windows` launches the app
5. ✅ Splash screen appears followed by login screen
6. ✅ Can login with admin/admin123

## Troubleshooting

### "Asset directories don't exist" error
```bash
# Create them manually
mkdir assets\images assets\animations assets\icons
```

### "MyApp class not found" error
```bash
# Pull latest changes
git pull origin main
```

### Build errors after clone
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows
```

### Database errors
```bash
# Delete old database (if exists)
del *.db
# Restart app
flutter run -d windows
```

---

**Ready to code?** Run the setup script and you're good to go! 🚀
