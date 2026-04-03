# 🛠️ AeroAssist AI - Developer Setup Guide

Complete step-by-step guide for developers to set up and work with AeroAssist AI locally.

---

## 📋 Table of Contents

1. [System Requirements](#system-requirements)
2. [Initial Setup](#initial-setup)
3. [Environment Configuration](#environment-configuration)
4. [Running the App](#running-the-app)
5. [Development Workflow](#development-workflow)
6. [Troubleshooting](#troubleshooting)
7. [Code Standards](#code-standards)
8. [Deployment](#deployment)

---

## 💻 System Requirements

### Minimum Requirements
- **OS**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **RAM**: 8GB (16GB recommended)
- **Disk Space**: 15GB free
- **Java**: JDK 11 or later (for Android development)
- **Git**: Latest version

### Software Dependencies
- **Flutter SDK**: 3.0.0 or later
- **Dart SDK**: 3.0.0 or later
- **Android Studio**: Latest version (for Android development)
- **Xcode**: 13+ (for iOS development, macOS only)
- **VS Code**: Latest version (with Flutter extension)

---

## 🚀 Initial Setup

### Step 1: Install Flutter

#### Windows
```powershell
# Download Flutter SDK
# https://flutter.dev/docs/get-started/install/windows

# Extract to a location (e.g., C:\src\flutter)
# Add Flutter to PATH:
# Control Panel → System → Advanced System Settings → Environment Variables
# Add C:\src\flutter\bin to PATH

# Verify installation
flutter doctor
```

#### macOS
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually from https://flutter.dev/docs/get-started/install/macos

# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

#### Linux
```bash
# Install dependencies
sudo apt-get install git curl clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

### Step 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/aeroassist-ai.git
cd aeroassist-ai

# Update Flutter
flutter upgrade
```

### Step 3: Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# Build generated files
flutter pub run build_runner build
```

### Step 4: Configure Devices

#### Android Emulator
```bash
# List available emulators
flutter emulators

# Create new emulator
flutter emulators create --name=aero_emulator

# Launch emulator
flutter emulators launch aero_emulator

# Or use Android Studio device manager
```

#### iOS Simulator (macOS only)
```bash
# Launch iOS Simulator
open -a Simulator.app

# Or from Xcode
Pod install for iOS dependencies
cd ios
pod install
cd ..
```

#### Physical Device

**Android:**
1. Enable Developer Mode (tap Build Number 7 times in Settings)
2. Enable USB Debugging in Developer Options
3. Connect via USB
4. Run `flutter devices` to verify

**iOS:**
1. Trust developer certificate on device
2. Connect via USB
3. Run `flutter devices` to verify

---

## ⚙️ Environment Configuration

### Create `.env` File

```bash
# Create file in project root
cat > .env << EOF

# App Configuration
APP_NAME=AeroAssist AI
APP_VERSION=1.0.0

# Firebase (Optional)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-bucket.appspot.com

# API Endpoints (Optional)
MAIN_API_URL=https://api.aeroassist.io

# Development
DEBUG_MODE=true
LOG_LEVEL=debug

EOF
```

### Android Configuration

**File:** `android/app/build.gradle`

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "io.aeroassist.ai"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<permissions>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
</permissions>
```

### iOS Configuration

**File:** `ios/Runner/Info.plist`

```xml
<dict>
    <key>NSCameraUsageDescription</key>
    <string>Used for component verification in maintenance procedures</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Used for voice commands and hands-free operation</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location data for maintenance site information</string>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Offline network communication</string>
</dict>
```

**File:** `ios/Podfile`

```ruby
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

---

## ▶️ Running the App

### Basic Commands

```bash
# Run on debug mode
flutter run

# Run with verbose output
flutter run -v

# Run on specific device
flutter run -d <device_name>

# List available devices
flutter devices
```

### Development Mode (Hot Reload)

```bash
# Start development session
flutter run

# Hot reload (fast refresh) - Press 'r'
# Full restart - Press 'R'
# Quit - Press 'q'
```

### Release Mode

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release

# Release IPA (iOS)
flutter build ios --release
```

---

## 🔄 Development Workflow

### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/component-name

# Update from main
git fetch origin
git rebase origin/main

# Commit with meaningful messages
git commit -m "feat: add visual lock system"

# Push to remote
git push origin feature/component-name

# Create Pull Request on GitHub
```

### Running Tests

```bash
# Run unit tests
flutter test

# Run specific test file
flutter test test/services/chat_service_test.dart

# Generate coverage report
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Fix formatting issues
dart format lib/

# Fix common issues
dart fix --apply lib/
```

### Building Generated Files

```bash
# Generate all required files
flutter pub run build_runner build

# Watch mode (auto-rebuild on changes)
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "Flutter SDK not found"
```bash
# Run doctor to diagnose
flutter doctor

# If PATH issue, add to bashrc/zshrc
export PATH="$PATH:$HOME/flutter/bin"

# Restart terminal and verify
flutter --version
```

#### 2. "Gradle sync failed"
```bash
# Clean Gradle cache
./gradlew clean

# Delete local.properties
rm android/local.properties

# Rebuild
flutter clean
flutter pub get
```

#### 3. "CocoaPods issues" (macOS)
```bash
# Update CocoaPods
sudo gem install cocoapods

# Pod install
cd ios
pod install --repo-update
cd ..
```

#### 4. "Camera permission denied"
```bash
# Android: Check AndroidManifest.xml has permissions
# iOS: Check Info.plist has NSCameraUsageDescription
# Device: Enabled permissions in app settings
```

#### 5. "Database locked error"
```bash
# Delete app cache
flutter clean

# Delete emulator and recreate
flutter emulators delete <emulator_name>
flutter emulators create --name=aero_emulator
```

### Getting Help

```bash
# Check Flutter doctor
flutter doctor

# Check package versions
flutter pub outdated

# Check for breaking changes
flutter upgrade

# Join Flutter community
# Slack: https://flutter.dev/community
# Discord: https://discord.gg/N7Yshp33k6
```

---

## 📝 Code Standards

### Naming Conventions

```dart
// Classes - PascalCase
class MaintenanceProcedure { }
class VisualLockService { }

// Methods/Variables - camelCase
void startMaintenance() { }
String processedData = '';

// Constants - lowerCamelCase with const
const int maxAttempts = 3;
const String appName = 'AeroAssist AI';

// Private members - leading underscore
void _internalMethod() { }
String _privateVariable = '';

// Enums - PascalCase
enum MaintenanceStatus { pending, inProgress, completed }
```

### Code Organization

```dart
// 1. Imports (organized alphabetically within groups)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/maintenance_models.dart';
import 'services/database_service.dart';

// 2. Class definition with documentation
/// Documentation comment explaining purpose
class ExampleWidget extends StatefulWidget {
  /// Constructor documentation
  const ExampleWidget({Key? key}) : super(key: key);

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

// 3. State class organized by lifecycle
class _ExampleWidgetState extends State<ExampleWidget> {
  // Variables
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    // Initialization
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  // Private methods
  void _privateMethod() { }
}
```

### Documentation

```dart
/// A service for managing maintenance procedures.
///
/// Handles CRUD operations for maintenance procedures and provides
/// search capabilities through [searchProcedures].
///
/// Example:
/// ```dart
/// final service = MaintenanceService();
/// final procedures = await service.getAllProcedures();
/// ```
class MaintenanceService { }

/// Verifies a component using camera and ML model.
///
/// Returns verification result with confidence score.
/// Throws [CameraException] if camera fails.
Future<VerificationResult> verifyComponent(String component);
```

### Error Handling

```dart
try {
  final result = await someFuture();
  setState(() => _data = result);
} on SpecificException catch (e) {
  _showErrorDialog('Error: ${e.message}');
} on Exception catch (e) {
  print('Unexpected error: $e');
} finally {
  // Cleanup
}
```

---

## 🚢 Deployment

### Pre-Release Checklist

- [ ] All tests passing
- [ ] Code analysis clean
- [ ] Update version in pubspec.yaml
- [ ] Update CHANGELOG.md
- [ ] Update README.md if needed
- [ ] Verify all assets included
- [ ] Test on multiple devices

### Android Play Store

```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build signed APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release

# Upload via Play Console
# https://play.google.com/console
```

### iOS App Store

```bash
# Build for iOS
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Build and archive in Xcode
# Product → Scheme → Runner (Release)
# Product → Archive

# Upload via Xcode or Transporter
```

### Web Deployment

```bash
# Build web version
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy

# Or deploy to Netlify/Vercel
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Firebase Integration](https://firebase.flutter.dev/)
- [Package Repository](https://pub.dev/)

---

## 🤝 Getting Support

- Check existing [GitHub Issues](https://github.com/yourusername/aeroassist-ai/issues)
- Create new issue with detailed description
- Join community discussions
- Contact development team

---

**Happy Coding!** ✈️
