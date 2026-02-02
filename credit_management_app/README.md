# Credit Management System - Flutter App

A comprehensive credit management system built with Flutter, featuring offline-first architecture, dummy data, and sync management. This app demonstrates best practices using **GetX** for state management, **MVVM** pattern, and **Clean Architecture**.

## 📱 Features

### Core Features
- **Customer Management**
  - Add, edit, and delete customers
  - View customer details and credit history
  - Credit score and risk level assessment
  - Customer search and filtering

- **Credit Management**
  - Create and manage credit accounts/loans
  - Track loan progress and payments
  - Approve/reject credit applications
  - View overdue credits and alerts

- **Transaction Management**
  - Record payments, credits, debits, and refunds
  - Multiple payment methods support
  - Transaction history and filtering
  - Real-time transaction tracking

- **Dashboard & Reports**
  - Overview statistics and KPIs
  - Credit summary and analytics
  - Transaction summaries
  - Risk distribution visualization

### Technical Features
- **Offline-First Architecture**: Works without internet connection
- **Sync Management**: Automatic sync when online, with pending queue
- **Dummy Data**: Pre-populated sample data for testing
- **Dark Mode Support**: System-based theme switching
- **Responsive Design**: Optimized for various screen sizes

## 🏗️ Architecture

This project follows **Clean Architecture** with three main layers:

```
lib/
├── core/                    # Core utilities and configurations
│   ├── constants/           # App constants and colors
│   ├── di/                  # Dependency injection
│   ├── theme/               # App theming
│   └── utils/               # Utility classes
│
├── data/                    # Data layer
│   ├── datasources/
│   │   └── local/           # Local database and sync services
│   ├── models/              # Data models (JSON serialization)
│   └── repositories/        # Repository implementations
│
├── domain/                  # Domain/Business layer
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business logic use cases
│
└── presentation/            # Presentation layer (MVVM)
    ├── bindings/            # GetX bindings
    ├── controllers/         # GetX controllers (ViewModels)
    └── views/               # UI screens and widgets
        ├── auth/
        ├── customers/
        ├── credits/
        ├── dashboard/
        ├── reports/
        ├── settings/
        ├── transactions/
        └── widgets/
```

## 🛠️ Technologies & Packages

| Package | Purpose |
|---------|---------|
| `get` | State management, navigation, dependency injection |
| `hive_flutter` | Local NoSQL database for offline storage |
| `connectivity_plus` | Network connectivity monitoring |
| `intl` | Date/number formatting and localization |
| `fl_chart` | Charts and data visualization |
| `uuid` | Unique ID generation |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd credit_management_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📖 Usage

### Demo Login
- Use any email and password, or tap "Demo Login" for quick access
- The app comes pre-loaded with sample customers, credits, and transactions

### Navigation
- **Dashboard**: Overview of all statistics and quick actions
- **Customers**: Manage customer profiles and credit limits
- **Credits**: Create and track credit accounts
- **Transactions**: Record and view all transactions
- **Reports**: Analytics and summaries
- **Settings**: App preferences and sync status

## 🔄 Offline Sync Management

The app implements a robust offline-first approach:

1. **Local Storage**: All data is stored locally using Hive
2. **Sync Queue**: Changes are queued when offline
3. **Auto-Sync**: Automatic sync when connection is restored
4. **Manual Sync**: Force sync from settings
5. **Sync Status**: Visual indicator shows sync status

```dart
// Sync status observable
syncService.isOnline        // Connection status
syncService.isSyncing       // Sync in progress
syncService.pendingSyncCount // Items waiting to sync
```

## 🎨 Theming

The app supports light and dark themes:

```dart
// Theme switching
Get.changeThemeMode(ThemeMode.light);
Get.changeThemeMode(ThemeMode.dark);
Get.changeThemeMode(ThemeMode.system);
```

## 📁 Project Structure Details

### Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repository Interfaces**: Abstract contracts for data operations
- **Use Cases**: Single-responsibility business logic operations

### Data Layer (Data Access)
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Concrete implementations of domain interfaces
- **Data Sources**: Local database and remote API services

### Presentation Layer (UI)
- **Controllers**: GetX controllers acting as ViewModels
- **Views**: Flutter widgets for UI
- **Bindings**: Dependency injection for routes

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📝 Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` for linting
- Format code with `dart format .`

## 🔐 Security Considerations

- No sensitive data is hardcoded
- Local storage uses Hive encryption (can be enabled)
- API tokens should be stored securely
- All network requests should use HTTPS

## 📄 License

This project is for demonstration purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## 📧 Support

For questions or support, please open an issue in the repository.

---

Built with ❤️ using Flutter
