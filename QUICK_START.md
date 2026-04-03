# ⚡ AeroAssist AI - Quick Start Guide

Get up and running in 5 minutes!

---

## 🚀 30-Second Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/aeroassist-ai.git
cd aeroassist-ai

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

**That's it!** 🎉

---

## 📱 Running on Your Device

### Android Device
```bash
# Enable USB debugging on your phone
# Connect phone via USB
# Run:
flutter run
```

### iOS Device (macOS only)
```bash
# Connect iPhone via USB
# Run:
flutter run
```

### Emulator/Simulator
```bash
# Start emulator first, then:
flutter run
```

---

## 🎯 First Time Use

### 1. Start Maintenance Procedure
1. Tap **"Start Maintenance"** on home screen
2. Enter your name
3. Select **"Engine Oil Change"** from dropdown
4. Tap **"Start Maintenance"**

### 2. Try AI Assistant
1. Go back to home screen
2. Tap **"AI Assistant"**
3. Type: `"What is torque for wing attachment?"`
4. Get instant offline response! ⚡

### 3. Search Manual
1. Tap **"Smart Manual"**
2. Search: `"torque"`
3. Browse all torque specifications

### 4. View History
1. Tap **"Maintenance History"**
2. See (empty for now - after completing procedures)

---

## 🔧 Troubleshooting

### App Won't Start?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### "No valid devices"?
```bash
# List devices
flutter devices

# If emulator: start it first
flutter emulators launch <name>
```

### "Module not found"?
```bash
# Restore packages
flutter pub get

# Generate required files
flutter pub run build_runner build
```

### Camera permission denied?
- **Android**: Go to Settings → Apps → AeroAssist AI → Permissions → Camera ✓
- **iOS**: Go to Settings → Privacy → Camera ✓

---

## 📁 Project Structure (Quick Reference)

```
aeroassist-ai/
├── lib/
│   ├── main.dart                    ← App entry point
│   ├── services/                    ← Business logic
│   │   ├── chat_service.dart        ← AI Chatbot
│   │   ├── database_service.dart    ← Data storage
│   │   └── visual_lock_service.dart ← Camera verification
│   └── ui/screens/                  ← User interface
│       ├── home_screen.dart
│       └── chat_screen.dart
├── assets/data/                     ← Offline data
│   ├── maintenance_procedures.json
│   └── torque_specs.json
├── pubspec.yaml                     ← Dependencies
└── README.md                        ← Full documentation
```

---

## 🎮 Common Commands

```bash
# Run normally
flutter run

# Run with output
flutter run -v

# Run in release mode (faster)
flutter run --release

# Restart app
flutter run -R

# Stop app
flutter run -q  # then press Ctrl+C

# List devices
flutter devices

# Build APK for Play Store
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 📚 What to Try Next

### 1. Explore Data Files
- Edit `assets/data/maintenance_procedures.json` to add custom procedures
- Edit `assets/data/torque_specs.json` to add torque values

### 2. Modify ChatBot
- Edit `lib/services/chat_service.dart` to improve responses
- Add more keyword patterns for better search

### 3. Customize UI
- Edit `lib/ui/screens/home_screen.dart` to change layout
- Modify colors in `lib/core/theme/app_theme.dart`

### 4. Add New Features
- Camera verification (ready to integrate ML model)
- Voice commands (packages already included)
- Multi-language support (speech_to_text ready)

---

## 🎥 Try These Features

### AI Chatbot - Ask These Questions
```
✓ "What is torque for bolt?"
✓ "How do I change engine oil?"
✓ "Safety warnings"
✓ "What tools are needed?"
✓ "Blue fluid leak diagnosis"
```

### Smart Manual - Search These
```
✓ "torque"
✓ "engine"
✓ "brake"
✓ "bolt"
✓ "M14"
```

---

## 🚀 Next Steps

### Immediate (Today)
- [ ] Run the app
- [ ] Test chat with questions
- [ ] Explore all screens
- [ ] Check offline functionality (turn WiFi off!)

### Short-term (This Week)
- [ ] Add custom maintenance procedures
- [ ] Customize torque specifications
- [ ] Update company info
- [ ] Configure for your aircraft types

### Medium-term (This Month)
- [ ] Set up camera verification
- [ ] Integrate ML model
- [ ] Build APK for distribution
- [ ] Test on multiple devices

### Long-term (This Quarter)
- [ ] Add voice support
- [ ] Multi-language support
- [ ] Cloud sync (optional)
- [ ] Deploy to Play Store

---

## 💡 Pro Tips

**Tip 1: Offline Testing**
```
Turn OFF your WiFi before launching the app to confirm
it's truly 100% offline. No cloud, no internet needed!
```

**Tip 2: Hot Reload**
```
While app is running, press 'r' to hot reload changes.
Press 'R' for full restart. Super helpful during development!
```

**Tip 3: Debug Console**
```
Press 'w' to show widget inspector
Press 'p' to toggle performance overlay
Press 'q' to quit
```

**Tip 4: Database**
```
SQLite database auto-created in device storage.
All data persisted locally - even after restarts!
```

---

## 📞 Getting Help

| Problem | Solution |
|---------|----------|
| App crashes | Run `flutter clean` then `flutter run` |
| Old app cached | Uninstall app first, then `flutter run` |
| Can't find device | Run `flutter devices` to list |
| Permissions denied | Check Android/iOS settings |
| Need documentation | See `README.md` or `SETUP_GUIDE.md` |

---

## 🎯 Success Checklist

- [ ] App launches successfully
- [ ] AI Chatbot responds to questions
- [ ] Smart Manual search works
- [ ] App works without internet
- [ ] Navigation between screens works
- [ ] Can capture maintenance procedures

---

## 🎉 You're Ready!

Your AeroAssist AI development environment is set up! 

**Start building the future of aircraft maintenance!** ✈️

---

### Next: Read Full Documentation

- **README.md** - Complete feature documentation
- **SETUP_GUIDE.md** - Detailed development setup
- **ARCHITECTURE.md** - System architecture details

---

**Happy Coding!** 🚀
