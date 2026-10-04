# Spendly

A modern Flutter expense tracker application that allows users to securely manage, analyse, and track their personal expenses using Firebase. Built with a clean feature-first architecture, beginner/intermediate-friendly Flutter state management (StatefulWidget, setState, StreamBuilder, ValueNotifier), and a polished Material 3 UI with full Light and Dark mode support.

---

## Features

### Authentication
- User registration with name, email, and password
- Email and password login
- Secure logout
- Persistent authentication state across sessions

### Expense Management
- Add expenses with title, amount, category, date, and optional notes
- Edit existing expenses
- Delete expenses with confirmation dialog
- Predefined expense categories (Food, Transport, Shopping, Health, Entertainment, Education, Utilities, Other)
- Real-time Firestore sync — changes reflect instantly across the UI

### Dashboard
- Current month total spending
- Current month expense count
- Up to 5 recent expenses displayed inline
- Quick access to add a new expense

### Expense History
- Full list of all expenses, sorted by date (newest first)
- Search by title, category, or notes
- Filter by category
- Filter by date (Today, This Week, This Month, Last Month, custom date)
- Combined filter and search in a single, unified view
- Active filter chips with individual clear actions
- Empty and loading states handled throughout

### Analytics
- Category spending donut chart (fl_chart)
- Monthly spending trend bar chart (last 6 months)
- Category breakdown list with percentage and transaction count
- Toggle between "This Month" and "All Time" views

### UI & Theme
- Light and Dark mode
- Theme toggle available in the Settings screen
- Theme preference persisted across app restarts (SharedPreferences)
- Responsive layout using Material 3 design principles
- Smooth loading states, empty states, and error states throughout

### Security
- Firebase Authentication protects all user accounts
- Firestore Security Rules restrict each user to their own expense data
- No credentials or secrets committed to the repository

---

## Technology Stack

| Technology | Version | Purpose |
|---|---|---|
| [Flutter](https://flutter.dev) | SDK | UI framework |
| [Dart](https://dart.dev) | ^3.13.1 | Programming language |
| [firebase_core](https://pub.dev/packages/firebase_core) | ^3.12.1 | Firebase initialisation |
| [firebase_auth](https://pub.dev/packages/firebase_auth) | ^5.5.1 | User authentication |
| [cloud_firestore](https://pub.dev/packages/cloud_firestore) | ^5.6.5 | Real-time expense storage |
| [fl_chart](https://pub.dev/packages/fl_chart) | ^1.1.1 | Expense analytics charts |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.5.5 | Theme preference persistence |
| [intl](https://pub.dev/packages/intl) | ^0.20.2 | Date and number formatting |

---

## Architecture

Spendly uses a simple, **beginner-friendly architecture** based entirely on standard Flutter mechanisms (StatefulWidget, setState, StreamBuilder, FutureBuilder, ValueNotifier) without third-party state management overhead.

Each feature folder is kept flat and self-contained — no extra `data/`, `domain/`, or `presentation/` subfolders. This makes the codebase easy to read and navigate for beginners and intermediate developers alike.

```
lib/
├── app/
│   ├── app.dart                    # Root MaterialApp and theme setup
│   └── routes.dart                 # Centralized navigation routes
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── app_dimensions.dart     # Spacing, radius, icon size tokens
│   ├── theme/
│   │   ├── app_colors.dart         # Colour palette (light + dark)
│   │   ├── app_text_styles.dart    # Typography definitions
│   │   ├── app_theme.dart          # ThemeData (light and dark)
│   │   └── theme_provider.dart     # ValueNotifier theme toggle + SharedPreferences
│   ├── utils/
│   │   ├── currency_formatter.dart # LKR currency formatting
│   │   └── date_formatter.dart     # Human-readable date helpers
│   └── widgets/
│       ├── app_card.dart           # Reusable themed card
│       ├── empty_state.dart        # Empty state placeholder
│       ├── loading_indicator.dart  # Centred loading spinner
│       ├── primary_button.dart     # Styled primary action button
│       ├── section_title.dart      # Section header with optional action
│       └── spendly_app_bar.dart    # Custom app bar
│
├── features/
│   ├── auth/                       # Auth feature (flat — no subfolders)
│   │   ├── auth_service.dart       # Firebase Auth wrapper
│   │   ├── auth_exception_handler.dart  # User-friendly error messages
│   │   ├── auth_gate.dart          # Routes to login or home based on auth state
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── splash_screen.dart
│   │
│   ├── expenses/                   # Expenses feature (flat)
│   │   ├── expense_service.dart    # Firestore CRUD for expenses
│   │   ├── firestore_exception_handler.dart
│   │   ├── expenses_screen.dart    # Full expense list with search & filters
│   │   ├── add_expense_screen.dart # Create / edit expense form
│   │   ├── models/                 # Plain Dart data models
│   │   │   ├── expense.dart
│   │   │   ├── expense_category.dart
│   │   │   ├── expense_filter_state.dart
│   │   │   ├── category_spending.dart
│   │   │   ├── monthly_expense_summary.dart
│   │   │   └── monthly_trend_item.dart
│   │   └── widgets/
│   │       ├── expense_list_tile.dart
│   │       └── category_selector.dart
│   │
│   ├── dashboard/                  # Dashboard feature (flat)
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── category_pie_chart.dart
│   │       ├── monthly_trend_bar_chart.dart
│   │       └── category_breakdown_tile.dart
│   │
│   ├── settings/                   # Settings feature (flat)
│   │   └── settings_screen.dart
│   │
│   └── navigation/                 # Bottom nav shell (flat)
│       └── main_navigation_shell.dart
│
├── firebase_options.dart
└── main.dart
```

### Data Flow

```
UI (Screens / Widgets)
        ↓  uses setState() / StreamBuilder / ValueListenableBuilder
Service Layer  (ExpenseService, AuthService)
        ↓  reads / writes
Firebase  (Cloud Firestore, Firebase Authentication)
```

- **StatefulWidget & setState()**: Used for local screen state (e.g. form inputs, active filter settings, loading indicators, navigation tab index).
- **StreamBuilder**: Directly subscribes to real-time streams (e.g. `AuthService.authStateChanges`, `ExpenseService.watchExpenses()`), keeping the UI reactive to Firestore changes without extra abstraction layers.
- **ValueNotifier / ValueListenableBuilder**: Simple, reactive theme mode management persisted via SharedPreferences.
- **Service Layer**: Pure Dart classes wrapping the Firebase SDK (`FirebaseAuth` and `FirebaseFirestore`) with CRUD methods and custom exception handling.
- **Domain Models**: Plain Dart classes with `fromFirestore` / `toFirestore` serialization methods.

---



### Authentication

Firebase Authentication is used for user account management with Email/Password sign-in enabled.



## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.13.1 included)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter/Dart extensions
- An Android emulator or physical device
- A [Firebase](https://firebase.google.com/) project with **Authentication** (Email/Password) and **Cloud Firestore** enabled

---

## Installation & Setup

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd spendy
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication → Email/Password** sign-in
3. Create a **Cloud Firestore** database
4. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. Run configuration from the project root:
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
6. Deploy the Firestore Security Rules shown above via the Firebase Console.

### 4. Run the application

```bash
flutter run
```

---

## Running the App

```bash
# Fetch all dependencies
flutter pub get

# Run in debug mode
flutter run

# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Run with release optimisations
flutter run --release
```

---

## Building a Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

> **Note:** Ensure `android/app/google-services.json` is present before building.

---

## Screenshots

<p align="center">
  <img src="screenshots/login.png" alt="Login screen" width="180">
  <img src="screenshots/register.png" alt="Register screen" width="180">
  <img src="screenshots/dashboard.png" alt="Dashboard screen" width="180">
  <img src="screenshots/expenses.png" alt="Expense history screen" width="180">
</p>

<p align="center">
  <img src="screenshots/add_expense.png" alt="Add expense screen" width="180">
  <img src="screenshots/analytics.png" alt="Analytics screen" width="180">
  <img src="screenshots/settings.png" alt="Settings screen" width="180">
</p>

## AI Tools Used

- **Google Antigravity** — used for development assistance and debugging.

- **ChatGPT** — used for technical guidance and troubleshooting.

All implementation was reviewed and tested before integration.
## Security

- **Firebase Authentication** manages all user sessions. Unauthenticated users cannot access any screen beyond login and registration.
- **Firestore Security Rules** enforce server-side access control. Each user can only read and write their own expense documents.
- **No secrets are committed** to this repository. The `google-services.json` file is excluded via `.gitignore`.

---

## Future Improvements

- Monthly and category-level budget limits with alerts
- Export expenses to CSV or PDF
- Recurring expense tracking
- Advanced multi-period analytics and comparison reports
- Push notifications for spending milestones
- Multi-currency support
- Cloud backup and restore

---

## Project Information

| Item | Detail |
|---|---|
| **App Name** | Spendly |
| **Version** | 0.1.0+1 |
| **Platform** | Android (Flutter cross-platform) |
| **Language** | Dart |
| **State Management** | setState / StreamBuilder / ValueNotifier |
| **Backend** | Firebase (Authentication + Firestore) |
