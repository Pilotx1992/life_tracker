# Life Tracker

<div align="center">

![Life Tracker Banner](https://via.placeholder.com/800x200/6366F1/FFFFFF?text=Life+Tracker)

**Track. Balance. Thrive.**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-blue.svg)](https://www.android.com)

*A comprehensive, offline-first life tracking application built with Flutter and Clean Architecture*

</div>

---

## 📱 Overview

**Life Tracker** is a comprehensive, offline-first life tracking application that helps you monitor and improve various aspects of your daily life. Built with Flutter and Material 3 design, it offers a beautiful, intuitive interface for tracking your health, finances, medications, reminders, and notes.

### Key Features

- 🏋️ **Weight Tracking** - Monitor your weight with BMI calculations and ideal weight ranges
- 💰 **Finance Management** - Track income, expenses, accounts, debts, bills, and financial commitments
- 💊 **Medication Tracker** - Schedule medications with multiple daily times and track adherence
- 🔔 **Smart Reminders** - Set standalone reminders or link them to medications, bills, and notes
- 📝 **Notes** - Create notes with checklists, attachments (images, files, voice notes), and PIN locking
- 📊 **Dashboard** - Personalized overview with customizable modules and quick actions
- ☁️ **Backup & Restore** - Encrypted backup to device storage with password protection
- 🎨 **Modern UI** - Material 3 design with light and dark themes
- 🌍 **Localization** - English and Arabic support (RTL ready)
- 🔒 **Privacy First** - All data stored locally with app lock (PIN/biometric) and database encryption ready
- ⚙️ **Settings** - Customizable theme, language, currency, date/time formats, and notification preferences

---

## 🏗️ Architecture

LifeMate follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── app/                      # App configuration
│   ├── di/                   # Dependency injection (Riverpod)
│   └── app_router.dart       # Navigation (GoRouter)
├── core/                     # Core utilities
│   └── export/               # Export service
├── data/                     # Data layer
│   ├── repos/                # Repository implementations
│   ├── services/             # Services (BLE, Health Connect, etc.)
│   └── sources/              # Data sources (Isar, API)
├── features/                 # Feature modules
│   ├── dashboard/            # Dashboard screen
│   ├── finance/              # Finance module
│   ├── health/               # Health module (Weight, Medication)
│   ├── notes/                # Notes module
│   ├── reminders/            # Reminders module
│   ├── settings/             # Settings module
│   ├── splash/               # Splash screen
│   └── onboarding/           # Onboarding flow
└── test/                     # Tests
```

### Design Patterns

- **Repository Pattern** - Abstract data access
- **Provider Pattern** - State management with Riverpod
- **Dependency Injection** - Centralized DI with Riverpod
- **Clean Architecture** - Separation of concerns

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 23+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/life_tracker.git
   cd life_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

---

## 📦 Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.2.0 | Navigation |
| `isar` | ^3.1.0+1 | Local database |
| `flutter_local_notifications` | ^17.2.1+2 | Local notifications |
| `google_fonts` | ^6.2.1 | Typography |
| `flutter_secure_storage` | ^9.2.2 | Secure storage for sensitive data |
| `local_auth` | ^2.2.0 | Biometric authentication |

### Feature Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `image_picker` | ^1.1.2 | Image selection for receipts/attachments |
| `file_picker` | ^8.0.6 | File selection for attachments |
| `audioplayers` | ^6.0.0 | Audio playback for voice notes |
| `crypto` | ^3.0.3 | Encryption for backups |
| `shared_preferences` | ^2.5.3 | App settings storage |
| `timezone` | ^0.9.3 | Timezone support for notifications |

See [pubspec.yaml](pubspec.yaml) for the complete list.

---

## 🎨 Features in Detail

### 1. Weight Tracking
- Track weight entries with date and optional notes
- Automatic BMI calculation based on user profile
- Ideal weight range display
- View weight history in chronological list
- Edit and delete entries

### 2. Finance Management
- **Accounts**: Multiple accounts (Bank, Cash, Card, E-Wallet) with balances
- **Expenses**: Track expenses with categories, accounts, dates, and receipt photos
- **Income**: Record income from various sources
- **Debts**: Track both "I Owe" and "Owed to Me" with payment history
- **Recurring Bills**: Schedule bills with automatic reminders and expense creation
- **Financial Commitments**: Set savings goals with progress tracking

### 3. Medication Tracker
- Add medications with name, dosage, and multiple daily times
- Track medication adherence with intake history
- Schedule notifications for each medication time
- View active medications and adherence statistics

### 4. Smart Reminders
- Create standalone reminders with title, description, date/time
- Recurring reminders (Daily, Weekly, Monthly, Custom)
- Priority levels (Low, Medium, High)
- Link reminders to medications, bills, or notes
- Notification actions (Mark Done, Snooze)

### 5. Notes
- Create and edit notes with title and content
- Color-coded notes for organization
- Checklist items within notes
- Attachments: images, files, and voice notes
- PIN locking for sensitive notes
- Grid and list view modes

### 6. Backup & Restore
- Create encrypted backups to device storage
- Password-protected backup files
- Restore from backup with conflict resolution (merge/replace)
- List and manage backup files

### 7. Settings & Security
- App lock with PIN and biometric authentication
- Theme selection (Light, Dark, System)
- Language selection (English, Arabic)
- Currency, date, and time format preferences
- Notification settings
- User profile management

---

## 🧪 Testing

### Run Tests

**Unit Tests:**
```bash
flutter test test/unit/
```

**Widget Tests:**
```bash
flutter test test/widget/
```

**Integration Tests:**
```bash
flutter test integration_test/
```

**All Tests:**
```bash
flutter test
```

### Test Coverage

- ✅ Unit tests for repositories
- ✅ Widget tests for screens
- ✅ Integration tests for user flows

---

## 📱 Screenshots

<div align="center">

| Dashboard | Weight Tracking | Finance |
|-----------|----------------|---------|
| ![Dashboard](https://via.placeholder.com/300x600/6366F1/FFFFFF?text=Dashboard) | ![Weight](https://via.placeholder.com/300x600/10B981/FFFFFF?text=Weight) | ![Finance](https://via.placeholder.com/300x600/F59E0B/FFFFFF?text=Finance) |

| Medications | Reminders | Notes |
|-------------|-----------|-------|
| ![Medications](https://via.placeholder.com/300x600/EF4444/FFFFFF?text=Medications) | ![Reminders](https://via.placeholder.com/300x600/8B5CF6/FFFFFF?text=Reminders) | ![Notes](https://via.placeholder.com/300x600/3B82F6/FFFFFF?text=Notes) |

</div>

---

## 🔐 Privacy & Security

- **Local-First** - All data stored locally on your device
- **Encrypted Backups** - AES-256-GCM encryption for cloud backups
- **No Data Collection** - No analytics, tracking, or data sharing
- **Open Source** - Transparent code for security audits
- **Privacy Policy** - See [PRIVACY.md](PRIVACY.md)

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Riverpod** - For excellent state management
- **Isar** - For the fast local database
- **Material Design** - For the design system
- **Lottie** - For beautiful animations

---

## 📞 Support

- **Issues** - [GitHub Issues](https://github.com/yourusername/life_tracker/issues)
- **Discussions** - [GitHub Discussions](https://github.com/yourusername/life_tracker/discussions)
- **Email** - support@lifetracker.app

---

## 🗺️ Roadmap

### v1.0 (Current - MVP)
- ✅ Weight tracking with BMI calculations
- ✅ Complete finance module (accounts, expenses, income, debts, bills, commitments)
- ✅ Medication tracking with notifications
- ✅ Standalone and linked reminders
- ✅ Notes with attachments and locking
- ✅ Dashboard with customization
- ✅ App lock (PIN/biometric)
- ✅ Backup & restore
- ✅ Settings and user profile
- ✅ Localization infrastructure (English/Arabic)

### v1.1 (Planned)
- 🔄 Export to CSV/PDF
- 🔄 Charts and analytics
- 🔄 BLE Smart Scale integration
- 🔄 Health Connect integration
- 🔄 iOS support

### v1.2 (Future)
- 🔮 Complete Arabic translations
- 🔮 Home screen widgets
- 🔮 Wear OS companion app
- 🔮 Advanced analytics and insights

### v2.0 (Vision)
- 🔮 Multi-device sync
- 🔮 Cloud backup (Google Drive)
- 🔮 Family sharing
- 🔮 Social features

---

## 📊 Project Status

### Implementation Status
- ✅ **Core Infrastructure**: Complete
- ✅ **Health Module**: Weight tracking, Medication reminders, User profile
- ✅ **Finance Module**: Accounts, Expenses, Income, Debts, Bills, Commitments
- ✅ **Notes Module**: Basic notes, Attachments, Voice notes, Note locking
- ✅ **Reminders Module**: Standalone reminders, Linked reminders
- ✅ **Settings Module**: App lock, Backup/Restore, General settings
- ✅ **Dashboard**: Summary cards, Customization
- ✅ **Testing**: Unit tests, Widget tests, Integration test structure
- 🔄 **Pre-Launch**: Code quality, documentation, performance optimization

### Project Statistics
- **Architecture**: Clean Architecture with Repository Pattern
- **State Management**: Riverpod
- **Database**: Isar (local, NoSQL)
- **Modules**: 6 major feature modules
- **Screens**: 20+ screens
- **Widgets**: 40+ custom widgets
- **Tests**: Unit, widget, and integration tests
- **Dependencies**: 30+ packages

---

<div align="center">

**Made with ❤️ using Flutter**

[⭐ Star us on GitHub](https://github.com/yourusername/life_tracker) • [📱 Download on Play Store](#) • [🐛 Report Bug](https://github.com/yourusername/life_tracker/issues)

</div>

