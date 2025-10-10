# Assets Directory

This directory contains all static assets used in the PAMS application.

## Structure

- `images/` - Application images and graphics
- `animations/` - Lottie animation files
- `icons/` - Custom icon files
- `fonts/` - Custom font files (Roboto family)

## Adding Assets

When adding new assets:

1. Place files in the appropriate subdirectory
2. Update `pubspec.yaml` if adding new font files
3. Reference assets using relative paths in code

## Example Usage

```dart
// Images
Image.asset('assets/images/logo.png')

// Fonts (already configured in pubspec.yaml)
Text('Hello', style: TextStyle(fontFamily: 'Roboto'))
```
