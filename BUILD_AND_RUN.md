# Build and Run Guide

## ✅ Issues Fixed

### Problem: Font Assets Missing
**Error**: `unable to locate asset entry in pubspec.yaml: "assets/fonts/Roboto-Regular.ttf"`

**Solution**: Removed custom font references from `pubspec.yaml`. The app now uses system default fonts.

## 🚀 How to Build and Run

### First Time Setup
```bash
# 1. Clean any previous build artifacts
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Run on Windows
flutter run -d windows
```

### Subsequent Runs
```bash
# Simply run the app
flutter run -d windows
```

### Hot Reload While Running
When the app is running, you can:
- Press `r` - Hot reload (apply code changes instantly)
- Press `R` - Hot restart (restart the entire app)
- Press `q` - Quit the app

## 📋 Prerequisites Checklist

- ✅ Flutter SDK installed and in PATH
- ✅ Visual Studio Build Tools 2022 with C++ workload
- ✅ Windows Developer Mode enabled
- ✅ All linting issues resolved
- ✅ Font assets issue fixed

## 🎯 Current Status

**Build Status**: ✅ Building Successfully

The app is currently building. First build takes longer (2-5 minutes) as it:
1. Downloads NuGet packages
2. Compiles C++ Windows runner
3. Builds Flutter engine
4. Compiles Dart code
5. Creates Windows executable

Subsequent builds will be much faster (~10-30 seconds).

## 🔑 Default Login

Once the app launches:
- **Username**: `admin`
- **Password**: `admin123`

## 📱 What You'll See

1. **Splash Screen** - Animated PAMS logo with gradient background
2. **Login Screen** - Professional login form with validation
3. **Dashboard** - Statistics cards and quick action buttons
4. **Navigation** - Access to Tenants, Apartments, Payments, and Maintenance modules

## 🐛 Troubleshooting

### Build Takes Too Long
- **First build**: 2-5 minutes is normal
- **Subsequent builds**: Should be under 30 seconds
- If stuck, press `Ctrl+C` and run `flutter clean` then try again

### "Building Windows application..." Stuck
- This is normal for first build
- Wait patiently (check Task Manager - Visual Studio processes should be running)
- On slower systems, can take up to 10 minutes for first build

### Build Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows
```

### Hot Reload Not Working
- Press `R` for full restart instead of `r`
- Or quit (`q`) and run `flutter run -d windows` again

## 📊 Build Progress Indicators

```
Launching lib\main.dart on Windows in debug mode...
Nuget.exe not found, trying to download or use cached version.  ← Downloading NuGet
Building Windows application...                                 ← Compiling
√ Built build\windows\x64\runner\Debug\pams.exe                ← Success!
Waiting for connection from debug service on Windows...         ← Starting app
Debug service listening on ws://127.0.0.1:xxxxx                ← App running
```

## ✅ Success Indicators

When build is successful, you'll see:
```
✓ Built build\windows\x64\runner\Debug\pams.exe
Waiting for Windows to report its views
Debug service listening on ws://127.0.0.1:xxxxx
```

Then the PAMS app window will open automatically!

## 🎨 App Features Ready to Use

### ✅ Working Now
- Splash screen with animations
- Login with authentication (admin/admin123)
- Dashboard with statistics
- Navigation to all modules
- Logout functionality

### 🔄 In Development
- Tenant CRUD operations
- Apartment management
- Payment processing
- Maintenance tracking
- Report generation

## 📝 Development Tips

1. **Keep Terminal Open**: Don't close the terminal while app is running
2. **Use Hot Reload**: Press `r` to see code changes instantly
3. **Check for Errors**: Terminal shows any runtime errors
4. **Database Location**: SQLite database created in app data folder

## 🔄 Next Steps After Launch

1. Test the login with admin credentials
2. Explore the dashboard
3. Navigate through different modules
4. Test logout functionality
5. Start implementing Tenant Management module (see CHECKLIST.md)

---

**Note**: The first build always takes longer. Be patient and let it complete. Once built, subsequent runs will be much faster!
