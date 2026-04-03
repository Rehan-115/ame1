# ✈️ AeroAssist AI - Offline AR-Powered Smart Maintenance Assistant

**Making Aircraft Maintenance Safer, Faster, and Fully Reliable**

> 🚀 An AI-powered maintenance assistant designed for aircraft maintenance engineers (AMEs) working in environments with little to no internet connectivity. With 100% offline capability, real-time camera verification, and automated documentation, AeroAssist AI transforms how technicians approach complex maintenance procedures.

---

## 📋 Table of Contents

- [Features](#features)
- [Core System Components](#core-system-components)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [Quick Start](#quick-start)
- [Demo Flow](#demo-flow)
- [Usage Guide](#usage-guide)
- [Development](#development)
- [Contributing](#contributing)

---

## ✨ Features

### 1. 👁️ **Visual Lock System** (AI Verification Engine)
- Camera-based real-time component verification
- AI-powered object detection (Teachable Machine ready)
- Prevents skipped steps with visual confirmation
- Confidence scoring for each verification

### 2. 🤖 **Offline AI Chatbot** (Intelligence Core)
- 100% offline operation - no internet required
- Keyword-based intelligent search
- Multi-language support ready
- Topics: Torque specs, procedures, diagnostics, safety

### 3. 📚 **Smart Manual System** (Instant Search)
- Replace bulky 2000+ page manuals
- Instant technical specification lookup
- Local database with:
  - Torque values for different components
  - Maintenance procedures
  - Component information
  - Safety warnings
  - Tools & equipment lists
  - Diagnostic troubleshooting

### 4. 📸 **Auto-Documentation Engine**
- Automatic step photo capture with timestamps
- Image + metadata storage
- Evidence trail for compliance
- No manual data entry

### 5. 🧾 **Maintenance History & Traceability**
- Complete audit trail of all work
- Technician accountability
- Time tracking
- Historical analytics
- Full report generation

---

## 🏗️ Core System Components

### Component 1: Visual Lock System
```
┌─────────────────────────────────────┐
│    Camera Input                     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  ML Model (Teachable Machine)       │
│  - Object Detection                 │
│  - Component Recognition            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Verification Engine                │
│  ✅ Part Found? → Unlock Next Step  │
│  ❌ Part Missing? → Warning         │
└─────────────────────────────────────┘
```

### Component 2: Offline AI System
```
User Query → Keyword Analysis → Database Search
                   ↓
    ┌────────────────┴────────────────┐
    ↓                                  ↓
Torque Specs              Procedures/Diagnostics
    ↓                                  ↓
Formatted Response ← ── ← ── ← ── ← Confidence Check
```

### Component 3: Auto-Documentation
```
Step Completion → Image Capture → Metadata Collection
       ↓               ↓                   ↓
   Timestamp    Component ID       Technician Info
                       ↓
              Database Storage
                       ↓
            HTML/Text Report Generation
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter | Cross-platform mobile (Android/iOS) |
| **State Management** | Provider/Riverpod | Efficient state handling |
| **Local Database** | SQLite | Offline data persistence |
| **AI/ML** | Teachable Machine / TensorFlow Lite | Object detection |
| **Camera** | camera package | Real-time video/photos |
| **Voice** | speech_to_text / flutter_tts | Hands-free commands |
| **Storage** | Firebase* | Optional cloud sync |
| **UI/UX** | Flutter ScreenUtil | Responsive design |

*Firebase is optional; all core features work 100% offline*

---

## 📁 Project Structure

```
aeroassist_ai/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart            # App theming
│   │   └── constants/
│   ├── features/                          # Feature modules
│   ├── models/
│   │   └── maintenance_models.dart       # Data models
│   ├── services/
│   │   ├── database_service.dart         # Local database
│   │   ├── chat_service.dart             # AI chatbot
│   │   ├── documentation_service.dart    # Report generation
│   │   └── visual_lock_service.dart      # Camera verification
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   ├── maintenance_start_screen.dart
│   │   │   ├── camera_verification_screen.dart
│   │   │   ├── smart_manual_screen.dart
│   │   │   └── maintenance_history_screen.dart
│   │   ├── widgets/
│   │   │   └── feature_card.dart
│   │   └── dialogs/
│   ├── utils/
│   │   ├── formatters.dart
│   │   └── validators.dart
│   └── data/
│       └── sample_data.dart
├── assets/
│   ├── data/
│   │   ├── maintenance_procedures.json   # Offline procedures
│   │   └── torque_specs.json             # Torque specifications
│   ├── models/                           # ML models (Teachable Machine)
│   └── images/
├── pubspec.yaml                          # Dependencies
├── README.md                             # This file
└── .gitignore
```

---

## 🚀 Installation & Setup

### Prerequisites
- **Flutter SDK** (3.0+)
- **Dart SDK** (included with Flutter)
- **Android SDK** (for Android testing) or **Xcode** (for iOS)
- **Git**

### Step 1: Clone Repository
```bash
git clone https://github.com/yourusername/aeroassist-ai.git
cd aeroassist-ai
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Camera Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Used for component verification in maintenance procedures</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice commands and hands-free operation</string>
```

### Step 4: Run the App
```bash
# Run on development device/emulator
flutter run

# Run in release mode (optimized)
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

### Step 5: Build APK/IPA
```bash
# Android APK
flutter build apk --release

# iOS App Bundle
flutter build ios --release
```

---

## ⚡ Quick Start

### 1. Start Maintenance Procedure
```
1. Tap "Start Maintenance" on home screen
2. Enter technician name
3. Select aircraft type
4. Choose maintenance procedure
5. Confirm and begin guided steps
```

### 2. Complete a Step with Camera Verification
```
1. Read step instruction
2. Align camera with component
3. AI verifies component presence
4. ✅ Step completes automatically
5. Photo captured as proof
```

### 3. Ask Technical Question
```
1. Tap "AI Assistant" on home screen
2. Ask: "What is torque for wing attachment?"
3. Get instant offline response
4. Ask follow-up questions
```

### 4. Search Manual
```
1. Open "Smart Manual"
2. Search: "bolt", "torque", "procedure"
3. View specifications and procedures
4. Copy values for reference
```

### 5. View Maintenance History
```
1. Open "Maintenance History"
2. See all completed procedures
3. View reports and photos
4. Export for compliance
```

---

## 🎬 Demo Flow (Hackathon Winning Flow)

```
START
  ↓
📱 App opens → "Welcome to AeroAssist AI"
  ↓
🎤 Say: "Start Engine Oil Change"
  ↓
👨‍🔧 Enter technician name & select procedure
  ↓
📖 Step 1 appears: "Locate fuel valve"
  ↓
📸 Camera verification begins
  ↓
❌ Wrong component? → ⚠️ Warning shown
  ↓
✅ Correct component? → ✓ Step unlocked
  ↓
📷 Photo auto-captured with timestamp
  ↓
🤖 User asks: "What torque for bolt?"
  ↓
🔌 App responds: "M14 = 150 Nm"
       (COMPLETELY OFFLINE!)
  ↓
📊 Repeat for all steps
  ↓
✅ Procedure complete
  ↓
📄 View auto-generated report with:
   - All step photos
   - Technician name
   - Duration: 32 minutes
   - Status: ✓ COMPLETE
   - Compliance ready
  ↓
⬇️ Export to PDF/JSON
  ↓
END
```

**💥 KEY JUDGE MOMENT:**
- Turn OFF WiFi during demo
- Ask: "What is torque specification?"
- App responds instantly from local database
- **Judges realize: Completely offline system** ✅

---

## 📖 Usage Guide

### Setting Up Your First Procedure

1. **Add Custom Procedures:**
   - Edit `assets/data/maintenance_procedures.json`
   - Add aircraft type, steps, tools
   - Include torque specifications

2. **Create Offline Database:**
   - App automatically creates SQLite database
   - All data stored locally on device
   - No cloud dependency

3. **Configure Aircraft Type:**
   - Edit aircraft configuration
   - Add custom components
   - Set default torque values

### Camera Verification Setup

1. **Train Detection Model:**
   - Use Google Teachable Machine (free online tool)
   - Train on component images
   - Export as TensorFlow Lite model
   - Place in `assets/models/`

2. **Reference Components:**
   - Edit `visual_lock_service.dart`
   - Add component detection logic
   - Update confidence thresholds

### Voice Integration

```dart
// Ask questions
"What is torque for bolt X?"
"How do I replace component Y?"
"What are safety warnings?"

// Commands
"Start maintenance"
"Next step"
"Take photo"
"Complete procedure"
```

---

## 🔧 Development

### Development Environment Setup

```bash
# Install Flutter
flutter pub global activate fvm  # Flutter Version Manager

# Set up emulator
flutter emulators --create
flutter emulators launch <emulator_id>

# Enable web (optional)
flutter config --enable-web
```

### Building Custom Features

#### Adding New Procedure
```dart
// models/maintenance_models.dart
const newProcedure = MaintenanceProcedure(
  name: 'Custom Procedure',
  aircraftType: 'Boeing 737',
  steps: [
    MaintenanceStep(
      stepNumber: 1,
      instruction: 'Do X',
      component: 'Component Y',
      requiresVerification: true,
    ),
  ],
);
```

#### Extending AI Chatbot
```dart
// services/chat_service.dart
String _customSearch(String query) {
  if (query.contains('custom')) {
    return 'Custom response here';
  }
  return 'Not found';
}
```

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

### Debugging

```bash
# Enable verbose logging
flutter run -v

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Hot reload during development
Press 'r' for hot reload
Press 'R' for hot restart
```

---

## 🚢 Deployment

### Android Play Store
```bash
flutter build apk --release
flutter build appbundle --release
# Upload to Google Play Console
```

### iOS App Store
```bash
flutter build ios --release
# Use Xcode or Transporter for upload
```

### Web (Optional)
```bash
flutter build web --release
# Deploy to Firebase Hosting, Netlify, etc.
```

---

## 🎯 Key Innovations

✅ **Visual Lock System** - AI verification prevents skipped steps
✅ **100% Offline AI** - Works in hangars without internet
✅ **Auto Documentation** - Tamper-proof maintenance records
✅ **Real-time Verification** - Camera-based component detection
✅ **Full Traceability** - Aviation compliance ready

---

## 📋 Compliance & Safety

- ✅ Follows aviation maintenance standards
- ✅ FAA/EASA ready architecture
- ✅ Tamper-proof digital records
- ✅ Full audit trail
- ✅ Role-based access (ready for implementation)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 License

This project is licensed under the MIT License - see LICENSE.md file for details.

---

## 👥 Team

- **Project Lead** - [Your Name]
- **Flutter Developer** - [Your Name]
- **ML/AI Specialist** - [Your Name]
- **UX Designer** - [Your Name]

---

## 🙏 Acknowledgments

- Flutter community for amazing framework
- Google Teachable Machine for easy ML
- Aviation maintenance community for feedback

---

## 📞 Contact & Support

- **Email**: support@aeroassist.io
- **Discord**: [Join our community](#)
- **GitHub Issues**: Report bugs here
- **Discussions**: Ask questions

---

## 🎥 Demo & Resources

- **Youtube Demo**: [Watch here](#)
- **Documentation**: Full API docs [here](#)
- **Video Tutorial**: Getting started [guide](#)
- **Sample Data**: Download sample procedures [here](#)

---

## 🔮 Future Roadmap

### Q1 2026
- [ ] Multi-language support (Hindi, Tamil, Spanish)
- [ ] Voice command enhancement
- [ ] Offline map integration

### Q2 2026
- [ ] Advanced ML models
- [ ] Real-time AR overlays
- [ ] Cloud sync (optional)

### Q3 2026
- [ ] Integration with maintenance tracking systems
- [ ] Advanced analytics dashboard
- [ ] Team collaboration features

### Q4 2026
- [ ] Enterprise deployment
- [ ] Custom enterprise solutions
- [ ] Certification programs

---

## 🌟 Pitch

> "AeroAssist AI transforms aircraft maintenance by combining 100% offline AI intelligence with real-time camera verification, removing guesswork and enabling technicians to work faster and safer without internet connectivity—making our solution the only maintenance assistant ready for aviation's harshest environments."

---

**Made with ❤️ for aircraft maintenance engineers worldwide** ✈️
