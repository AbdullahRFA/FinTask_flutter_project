lib/
├── main.dart              <-- Entry point
├── core/                  <-- Things used EVERYWHERE (Global)
│   ├── constants/         <-- Colors, Strings, Asset paths
│   ├── utils/             <-- Helper functions (Date formatters, Validators)
│   └── widgets/           <-- Reusable UI (Custom Buttons, TextFields)
├── features/              <-- The meat of your app (Modular)
│   ├── auth/              <-- FR-1 to FR-7
│   │   ├── data/          <-- Firebase connection logic
│   │   ├── presentation/  <-- LoginScreen, SignupScreen
│   │   └── domain/        <-- User Models
│   ├── wallet/            <-- FR-8 to FR-13
│   ├── expenses/          <-- FR-14 to FR-20
│   └── analytics/         <-- FR-33 to FR-37
└── config/                <-- Routes, Themes


dependencies:
flutter:
sdk: flutter

# State Management (NFR-14)
# We will use Riverpod. It is the modern evolution of Provider.
# Why? It catches errors at compile-time (while you write code)
# rather than crashing the app at runtime.
flutter_riverpod: ^2.5.1

# Backend (Section 2.4)
firebase_core: ^2.27.0
firebase_auth: ^4.17.8
cloud_firestore: ^4.15.8

# Utilities
intl: ^0.19.0           # For formatting dates (FR-14) and currency
uuid: ^4.3.3            # To generate unique IDs for ExpenseItem (Section 6.1)
google_fonts: ^6.1.0    # For UI Polish (NFR-11)